local M = {}

local config = require("freeze-code.config")

local job = {}

local stdio = { stdout = "", stderr = "" }

---Closing job in a safely way
---@param h uv_pipe_t|uv_process_t: `stdout|stderr|handle`
local function safe_close(h)
  if not h:is_closing() then
    h:close()
  end
end

local function stop_job()
  if job == nil then
    return
  end
  if not job.stdout == nil then
    job.stdout:read_stop()
    safe_close(job.stdout)
  end
  if not job.stderr == nil then
    job.stderr:read_stop()
    safe_close(job.stderr)
  end
  if not job.handle == nil then
    safe_close(job.handle)
  end
  job = nil
end

---The function called on exit of from the event loop
---@param msg string: Message to display if success
---@return function cb: Schedule wrap callback function
local function on_exit(msg)
  return vim.schedule_wrap(function(code, _)
    if code == 0 then
      vim.notify("[freeze-code] " .. msg, vim.log.levels.INFO, { title = "FreezeCode" })
    else
      vim.notify(stdio.stdout, vim.log.levels.ERROR, { title = "Freeze" })
    end
    stop_job()
  end)
end

local function on_output(err, data)
  if err then
    -- what should we really do here?
    vim.api.nvim_err_writeln(vim.inspect(err))
  end
  if data then
    stdio.stdout = stdio.stdout .. data
  end
end

---Checks if the given cmd executes.
---@param cmd string
---@param path_to_check string
---@return boolean success: true if executes, false otherwise
local function check_executable(cmd, path_to_check)
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

---Freeze file with a range
---@param s_line? number: line to start range
---@param e_line? number: line to start range
---@param opts? FreezeConfig
M.freeze = function(s_line, e_line, opts)
  config = vim.tbl_extend("force", {}, config, opts or {})
  s_line = s_line or 1
  e_line = e_line or vim.api.nvim_buf_line_count(0)

  local cmd = config.freeze_path

  if not check_executable("freeze", cmd) then
    return
  end

  local lang = vim.api.nvim_buf_get_option(0, "filetype")
  local file = vim.api.nvim_buf_get_name(0)
  local conf = config.freeze_config.config
  local dir = config.dir
  local theme = config.freeze_config.theme
  local output = config.freeze_config.output

  if output ~= "freeze" then
    local t_stamp = os.date("%Y%m%d%H%M%S")
    local filename = file:match("^.+/(.*)$") or file

    output = string.format("%s_%s_%s", tostring(t_stamp), filename, output)
  end

  config.output = dir .. "/" .. output .. ".png"

  local cmd_args = {
    "--output",
    config.output,
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

  job = {}
  job.stdout = vim.loop.new_pipe(false)
  job.stderr = vim.loop.new_pipe(false)

  local job_opts = {
    args = cmd_args,
    stdio = { nil, job.stdout, job.stderr },
  }

  local msg = "frozen frame in path=" .. config.output
  job.handle = vim.loop.spawn(cmd, job_opts, on_exit(msg))
  vim.loop.read_start(job.stdout, vim.schedule_wrap(on_output))
  vim.loop.read_start(job.stderr, vim.schedule_wrap(on_output))
end

return M
