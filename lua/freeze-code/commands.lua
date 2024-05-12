local M = {}

local os_utils = require("freeze-code.utils").os
local is_win = os_utils.is_win
local is_macos = os_utils.is_macos
-- local is_unix = os_utils.is_unix

local tmp_freeze_path = "/tmp/freeze-code.nvim"

local setup_bin_path = function()
  if not vim.loop.fs_stat(tmp_freeze_path) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/AlejandroSuero/freeze-code.nvim.git",
      "--branch=main", -- latest stable release
      tmp_freeze_path,
    })
  end
end

M.job = {}

M.stdio = { stdout = "", stderr = "" }

---Closing job in a safely way
---@param h uv_pipe_t|uv_process_t: `stdout|stderr|handle`
local function safe_close(h)
  if not h:is_closing() then
    h:close()
  end
end

local function stop_job()
  if M.job == nil then
    return
  end
  if not M.job.stdout == nil then
    M.job.stdout:read_stop()
    safe_close(M.job.stdout)
  end
  if not M.job.stderr == nil then
    M.job.stderr:read_stop()
    safe_close(M.job.stderr)
  end
  if not M.job.handle == nil then
    safe_close(M.job.handle)
  end
  M.job = nil
end

---The function called on exit of from the event loop
---@param msg string: Message to display if success
---@return function cb: Schedule wrap callback function
function M.on_exit(msg)
  local freeze_code = require("freeze-code")
  return vim.schedule_wrap(function(code, _)
    if code == 0 then
      vim.notify("[freeze-code] " .. msg, vim.log.levels.INFO, { title = "FreezeCode" })
    else
      vim.notify(M.stdio.stdout, vim.log.levels.ERROR, { title = "Freeze" })
    end
    if freeze_code.config.copy == true then
      freeze_code.copy(freeze_code.config)
    end
    stop_job()
  end)
end

function M.on_output(err, data)
  if err then
    -- what should we really do here?
    vim.api.nvim_err_writeln(vim.inspect(err))
  end
  if data then
    M.stdio.stdout = M.stdio.stdout .. data
  end
end

---Checks if the given cmd executes.
---@param cmd string
---@param path_to_check string
---@return boolean success: true if executes, false otherwise
function M.check_executable(cmd, path_to_check)
  if vim.fn.executable(cmd) == 0 then
    vim.api.nvim_err_write(
      string.format(
        "[freeze-code] could not execute `" .. cmd .. "` binary in path=%s . make sure you have the right config",
        path_to_check
      )
    )
    return false
  end
  return true
end

local copy_by_os = function(opts)
  setup_bin_path()
  local bin_path = tmp_freeze_path .. "/bin"
  local binaries = {
    macos = bin_path .. "/pngcopy-macos",
    linux = bin_path .. "/pngcopy-linux",
    windows = bin_path .. "/pngcopy-windows.ps1",
  }

  local cmd = ""
  if is_win then
    cmd = "pwsh " .. binaries.windows .. " " .. opts.output
    return os.execute(cmd)
  elseif is_macos then
    cmd = "sh " .. binaries.macos .. " " .. opts.output
    return os.execute(cmd)
  end
  cmd = "sh " .. binaries.linux .. " " .. opts.output
  os.execute(cmd)
end

M.copy = function(opts)
  copy_by_os(opts)
  local cmd = ""
  if is_win then
    cmd = "rm -r -Force " .. tmp_freeze_path
  else
    cmd = "rm -rf " .. tmp_freeze_path
  end
  os.execute(cmd)
end

return M
