local cfg = require("freeze-code.config")
local u = require("freeze-code.utils")
local logger = u.logger

local FreezeBinaryFetcher = {}

---@class FreezeBinaryFetcher
---@field go_installation function: installs `freeze` using `go install github.com/charmbracelet/freeze@latest`
---Freeze installation using `go install`
---@param opts FreezeCodeConfig
function FreezeBinaryFetcher:go_installation(opts)
  local cmd_args = {
    "go",
    "install",
    "github.com/charmbracelet/freeze@latest",
  }
  local stdio = { stdout = "", stderr = "" }
  local job = nil

  local function on_output(err, data)
    if err then
      logger.err(err)
    end
    if data then
      stdio.stderr = stdio.stderr .. data
    end
  end
  local callbacks = {
    on_sterr = vim.schedule_wrap(function(_, data, _)
      local out = table.concat(data, "\n")
      on_output(out)
    end),
    on_exit = vim.schedule_wrap(function()
      opts._installed = true
      opts.freeze_path = vim.env.HOME .. "/go/bin/freeze"
      opts.install_path = opts.freeze_path
      logger.warn("[freeze-code] go install github.com/charmbracelet/freeze@latest completed")
      cfg.setup(opts)
      vim.fn.jobstop(job)
    end),
  }
  job = vim.fn.jobstart(cmd_args, callbacks)
end

---@class FreezeBinaryFetcher
---@field agnostic_installation function: installs `freeze` using `cURL` from GitHub release
---Freeze installation using GitHub release
---@param opts FreezeCodeConfig
function FreezeBinaryFetcher:agnostic_installation(opts)
  local os_name = u.get_os_info()
  local release_url = u.release_file_url()
  if release_url == "" then
    logger.err("could not get release file")
    return
  end

  local install_path = vim.fn.expand(opts.install_path)
  if install_path == "" then
    install_path = vim.fn.expand("~/.local/bin")
  end
  local output_filename = "freeze.tar.gz"
  local download_command = { "curl", "-sL", "-o", output_filename, release_url }
  local extract_command = { "tar", "-zxf", output_filename, "-C", install_path }
  -- vim.loop.spawn("rm", { args = { "-rf", install_path .. "/" .. u.get_freeze_filename() } })
  local rm_command_args = { "-rf", install_path .. "/" .. u.get_freeze_filename() }
  if os_name == "Windows" then
    extract_command = { "Expand-Archive", output_filename, install_path }
    rm_command_args = { "-r", "-Force", install_path .. "/" .. u.get_freeze_filename() }
  end
  local binary_path = vim.fn.expand(table.concat({ install_path, u.get_freeze_filename() .. "/freeze" }, "/"))

  -- check for existing files / folders
  if vim.fn.isdirectory(install_path) == 0 then
    vim.loop.fs_mkdir(install_path, tonumber("777", 8))
  end

  if vim.fn.filereadable(binary_path) == 1 then
    local success = vim.loop.fs_unlink(binary_path)
    if not success then
      logger.err("[freeze-code.nvim] ERROR: `freeze` binary could not be removed!")
      return
    end
  end
  local stdio = { stdout = "", stderr = "" }
  local job = nil

  local function on_output(err, data)
    if err then
      logger.err(err)
    end
    if data then
      stdio.stderr = stdio.stderr .. data
    end
  end

  -- download and install the freeze binary
  local callbacks = {
    on_sterr = vim.schedule_wrap(function(_, data, _)
      local out = table.concat(data, "\n")
      on_output(out)
    end),
    on_exit = vim.schedule_wrap(function()
      logger.info_fmt("[freeze-code.nvim] extracting release with `%s`", table.concat(extract_command, " "))
      vim.fn.system(extract_command)
      if vim.v.shell_error ~= 0 then
        logger.err("[freeze-code.nvim] ERROR: extracting release failed")
        return
      end
      -- remove the archive after completion
      if vim.fn.filereadable(output_filename) == 1 then
        local success = vim.loop.fs_unlink(output_filename)
        if not success then
          logger.err("[freeze-code.nvim] ERROR: existing archive could not be removed")
          return
        end
      end
      vim.loop.spawn("mv", { args = { binary_path, install_path .. "/freeze" } })
      binary_path = install_path .. "/freeze"
      opts.freeze_path = binary_path
      opts._installed = true
      opts.install_path = install_path
      logger.warn_fmt("[freeze-code.nvim] `freeze` binary installed in installed in path=%s", cfg.config.freeze_path)
      vim.loop.spawn("rm", { args = rm_command_args })
      logger.warn_fmt("[freeze-code.nvim] `freeze` binary installed in path=%s", cfg.config.freeze_path)
      cfg.setup(opts)
      vim.fn.jobstop(job)
    end),
  }
  logger.info_fmt("[freeze-code.nvim] downloading release from `%s`", release_url)
  job = vim.fn.jobstart(download_command, callbacks)
end

---@class FreezeBinaryFetcher
---@field install_freeze function: `freeze` installation process
---Install freeze for the user
---@param opts FreezeCodeConfig
function FreezeBinaryFetcher:install_freeze(opts)
  if u.check_executable("go", vim.fn.exepath("go")) then
    logger.warn("[freeze-code.nvim] go install github.com/charmbracelet/freeze@latest completed")
    self:go_installation(opts)
    return
  end
  logger.info("[freeze-code.nvim] Installing info with `curl`")
  self:agnostic_installation(opts)
end

return FreezeBinaryFetcher
