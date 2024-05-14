---@meta
---@class FreezeConfig
---@field output string: Freeze output filename `--output "freeze.png"`
---@field theme string: Freeze theme `--theme "default"`
---@field config string: Freeze configuration `--config "base"`

---@class FreezeCodeConfig
---@field freeze_path string: Path to `freeze` executable
---@field copy_cmd string: Path to copy `image/png` to clipboard command
---@field copy boolean: Open image after creation option
---@field open boolean: Open image after creation option
---@field dir string: Directory to create image
---@field freeze_config FreezeConfig
---@field output? string: output filename
---@field install_path string: path in where to install `freeze`
---@field _installed boolean:

---@type FreezeConfig
local freeze_config = {
  output = "freeze",
  config = "base",
  theme = "default",
}

---@class FreezeCode
---@field config FreezeCodeConfig
---@type FreezeCodeConfig
local config = {
  _installed = vim.fn.exepath("freeze") ~= "",
  install_path = vim.env.HOME .. "/.local/bin",
  freeze_path = vim.fn.exepath("freeze"),
  copy_cmd = vim.env.HOME .. "/dev/nvim_plugins/freeze-code.nvim/bin/pngcopy-macos",
  copy = false,
  open = false,
  dir = vim.env.PWD,
  freeze_config = freeze_config,
  output = nil,
}

---@type FreezeCode|{}
local freeze_code = {}

local freeze_version = "0.1.6"

local logger = require("freeze-code.utils").logger

local commands = require("freeze-code.commands")

freeze_code.config = config

---@class FreezeCode
---@field copy function: Copying image to clipboard
freeze_code.copy = function(opts)
  commands.copy(opts)
end

local create_autocmds = function()
  vim.api.nvim_create_user_command("Freeze", function(opts)
    if opts.count > 0 then
      freeze_code.freeze(opts.line1, opts.line2)
    else
      freeze_code.freeze()
    end
  end, {
    range = true,
  })
end

local get_os_info = function()
  local os_name, arch

  local raw_os = vim.loop.os_uname().sysname
  local raw_arch = jit.arch
  local os_patterns = {
    ["Windows"] = "Windows",
    ["Windows_NT"] = "Windows",
    ["Linux"] = "Linux",
    ["Darwin"] = "Darwin",
    ["BSD"] = "Freebsd",
  }

  local arch_patterns = {
    ["x86"] = "i386",
    ["x64"] = "x86_64",
    ["arm"] = "arm7",
    ["arm64"] = "arm64",
  }

  os_name = os_patterns[raw_os]
  arch = arch_patterns[raw_arch]

  return os_name, arch
end

-- Get the filename for the release (e.g. freeze_<version>_<os>_<arch>)
---@return string
local function get_freeze_filename()
  local os_name, arch = get_os_info()

  if os_name == nil or arch == nil then
    vim.notify("os not supported or could not be parsed", vim.log.levels.ERROR, { title = "Freeze" })
    return ""
  end
  local filename = "freeze_" .. freeze_version .. "_" .. os_name .. "_" .. arch
  return filename
end

---Get the release archive file extension depending on OS
---@return string extension
local function get_archive_extension()
  local os_name, _ = get_os_info()

  return (os_name == "Windows" and ".zip" or ".tar.gz")
end

---Get the release file for the right OS and Architecture from official release
---page, https://github.com/charmbracelet/freeze/releases, for the specified version
---@return string release_url
local function release_file_url()
  -- check pre-existence of required programs
  if vim.fn.executable("curl") == 0 or vim.fn.executable("tar") == 0 then
    vim.notify("curl and/or tar are required", vim.log.levels.ERROR, { title = "Freeze" })
    return ""
  end

  local filename = get_freeze_filename() .. get_archive_extension()

  -- create the url, filename based on os and arch
  return "https://github.com/charmbracelet/freeze/releases/download/v" .. freeze_version .. "/" .. filename
end

---@class FreezeCode
---@field go_install_freeze function: installs `freeze` using `go install github.com/charmbracelet/freeze@latest`
---Freeze installation using `go install`
---@param opts FreezeCodeConfig
freeze_code.go_install_freeze = function(opts)
  local cmd_args = {
    "go",
    "install",
    "github.com/charmbracelet/freeze@latest",
  }
  local stdio = { stdout = "", stderr = "" }

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
      freeze_code.setup(opts)
      logger.warn("[freeze-code] go install github.com/charmbracelet/freeze@latest completed")
      create_autocmds()
    end),
  }
  vim.fn.jobstart(cmd_args, callbacks)
end

---@class FreezeCode
---@field agnostic_install_freeze function: installs `freeze` using `cURL` from GitHub release
---Freeze installation using GitHub release
---@param opts FreezeCodeConfig
freeze_code.agnostic_install_freeze = function(opts)
  local os_name = get_os_info()
  local release_url = release_file_url()
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
  -- vim.loop.spawn("rm", { args = { "-rf", install_path .. "/" .. get_freeze_filename() } })
  local rm_command_args = { "-rf", install_path .. "/" .. get_freeze_filename() }
  if os_name == "Windows" then
    extract_command = { "Expand-Archive", output_filename, install_path }
    rm_command_args = { "-r", "-Force", install_path .. "/" .. get_freeze_filename() }
  end
  local binary_path = vim.fn.expand(table.concat({ install_path, get_freeze_filename() .. "/freeze" }, "/"))

  -- check for existing files / folders
  if vim.fn.isdirectory(install_path) == 0 then
    vim.loop.fs_mkdir(install_path, tonumber("777", 8))
  end

  if vim.fn.filereadable(binary_path) == 1 then
    local success = vim.loop.fs_unlink(binary_path)
    if not success then
      logger.err("[freeze-code] ERROR: `freeze` binary could not be removed!")
      return
    end
  end
  local stdio = { stdout = "", stderr = "" }

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
      logger.info_fmt("[freeze-code] extracting release with `%s`", table.concat(extract_command, " "))
      vim.fn.system(extract_command)
      -- remove the archive after completion
      if vim.fn.filereadable(output_filename) == 1 then
        local success = vim.loop.fs_unlink(output_filename)
        if not success then
          logger.err("[freeze-code] ERROR: existing archive could not be removed")
          return
        end
      end
      vim.loop.spawn("mv", { args = { binary_path, install_path .. "/freeze" } })
      binary_path = install_path .. "/freeze"
      opts.freeze_path = binary_path
      opts._installed = true
      opts.install_path = install_path
      freeze_code.setup(opts)
      vim.loop.spawn("rm", { args = rm_command_args })
      logger.warn_fmt("[freeze-code] `freeze` binary installed in installed in path=%s", freeze_code.config.freeze_path)
      freeze_code.setup(opts)
      create_autocmds()
    end),
  }
  logger.info_fmt("[freeze-code] downloading release from `%s`", release_url)
  vim.fn.jobstart(download_command, callbacks)
end

---@class FreezeCode
---@field install_freeze function: `freeze` installation process
---Install freeze for the user
---@param opts FreezeCodeConfig
freeze_code.install_freeze = function(opts)
  if commands.check_executable("go", vim.fn.exepath("go")) then
    logger.warn("[freeze-code] go install github.com/charmbracelet/freeze@latest completed")
    freeze_code.go_install_freeze(opts)
    return
  end
  logger.info("[freeze-code] Installing info with `curl`")
  freeze_code.agnostic_install_freeze(opts)
end

---@class FreezeCode
---@field freeze function: Running `freeze` function
---Freeze file with a range
---@param s_line? number: line to start range
---@param e_line? number: line to start range
freeze_code.freeze = function(s_line, e_line)
  if not freeze_code.config._installed then
    logger.warn("[freeze-code] `freeze` not installed")
    freeze_code.install_freeze(freeze_code.config)
    return
  end

  s_line = s_line or 1
  e_line = e_line or vim.api.nvim_buf_line_count(0)

  local cmd = freeze_code.config.freeze_path

  if not commands.check_executable("freeze", cmd) then
    return
  end

  local lang = vim.api.nvim_buf_get_option(0, "filetype")
  local file = vim.api.nvim_buf_get_name(0)
  local conf = freeze_code.config.freeze_config.config
  local dir = freeze_code.config.dir
  local theme = freeze_code.config.freeze_config.theme
  local output = freeze_code.config.freeze_config.output

  if output ~= "freeze" then
    local t_stamp = os.date("%Y%m%d%H%M%S")
    local filename = file:match("^.+/(.*)$") or file

    output = string.format("%s_%s_%s", tostring(t_stamp), filename, output)
  end

  freeze_code.config.output = dir .. "/" .. output .. ".png"

  local cmd_args = {
    "--output",
    freeze_code.config.output,
    "--language",
    lang,
    "--lines",
    s_line .. "," .. e_line,
    "--config",
    conf,
    "--theme",
    theme,
    file,
  }

  commands.job = {}
  commands.job.stdout = vim.loop.new_pipe(false)
  commands.job.stderr = vim.loop.new_pipe(false)

  local job_opts = {
    args = cmd_args,
    stdio = { nil, commands.job.stdout, commands.job.stderr },
  }

  local msg = "🍧 frozen frame in path=" .. freeze_code.config.output
  commands.job.handle = vim.loop.spawn(cmd, job_opts, commands.on_exit(msg))
  vim.loop.read_start(commands.job.stdout, vim.schedule_wrap(commands.on_output))
  vim.loop.read_start(commands.job.stderr, vim.schedule_wrap(commands.on_output))
end

---@class FreezeCode
---@field setup function: setup function for `freeze-code.nvim`
---freeze-code's set up function
---@param opts FreezeCodeConfig|nil
freeze_code.setup = function(opts)
  freeze_code.config = vim.tbl_deep_extend("force", {}, freeze_code.config, opts or {})
  create_autocmds()
end

return freeze_code
