local M = {}

local utils = require("freeze-code.utils")
local config = require("freeze-code.config")
local logger = utils.logger
local os_utils = utils.os
local is_win = os_utils.is_win
local is_macos = os_utils.is_macos
local is_unix = os_utils.is_unix

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
function M.on_exit(msg, opts)
  local cfg = require("freeze-code.config")
  return vim.schedule_wrap(function(code, _)
    if code == 0 then
      vim.notify("[freeze-code.nvim] " .. msg, vim.log.levels.INFO, { title = "FreezeCode" })
    else
      vim.notify(M.stdio.stdout, vim.log.levels.ERROR, { title = "Freeze" })
    end
    if cfg.config.copy == true then
      M.copy(cfg.config)
    end
    if cfg.config.open == true then
      M.open(cfg.config)
    end
    if opts and opts.freeze then
      vim.wait(5000, function()
        local image_path = vim.loop.fs_fstat(opts.freeze.output)
        return image_path ~= nil
      end)
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
    logger.err_fmt(
      "[freeze-code] could not execute `" .. cmd .. "` binary in path=`%s` . make sure you have the right config",
      path_to_check
    )
    return false
  end
  return true
end

local copy_by_os = function(opts)
  local cmd = {}
  local filename = vim.fn.expand(opts.output)
  if config.config.copy_cmd ~= "" then
    local command = string.gsub(config.config.copy_cmd, "filename", filename)
    cmd = { command }
    return vim.fn.system(cmd)
  end
  if vim.fn.executable("gclip") ~= 0 then
    cmd = { "gclip", "-copy", "-f", filename }
    return vim.fn.system(cmd)
  end
  if is_win then
    cmd = {
      "Add-Type",
      "-AssemblyName",
      "System.Windows.Forms",
      ";",
      "[Windows.Forms.Clipboard]::SetImage($[System.Drawing.Image]::FromFile(" .. filename .. "))",
    }
  elseif is_macos then
    cmd = {
      "osascript",
      "-e",
      'set the clipboard to (read (POSIX file "' .. filename .. '") as {«class PNGf»})',
    }
  end
  if is_unix then
    if vim.env.XDG_SESSION_TYPE == "x11" then
      cmd = { "xclip", "-selection", "clipboard", "-t", "image/png", "-i", filename }
    else
      cmd = { "sh", "-c", "wl-copy <" .. filename }
    end
  end
  return vim.fn.system(cmd)
end

M.copy = function(opts)
  copy_by_os(opts)
  if vim.v.shell_error ~= 0 then
    logger.err_once("[freeze-code.nvim] error while copying image to clipboard")
    return
  end
  logger.info("[freeze-code.nvim] image copied to clipboard")
end

local open_by_os = function(opts)
  local cmd = {}
  local filename = vim.fn.expand(opts.output)
  if is_win then
    cmd = { "explorer", filename }
  else
    cmd = { "open", filename }
  end
  return vim.fn.system(table.concat(cmd, " "))
end

M.open = function(opts)
  open_by_os(opts)
  if vim.v.shell_error ~= 0 then
    logger.err_once("[freeze-code.nvim] error while opening image")
    return
  end
end

return M
