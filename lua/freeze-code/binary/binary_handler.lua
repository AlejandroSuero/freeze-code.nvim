local binary_fetcher = require("freeze-code.binary.binary_fetcher")
local cfg = require("freeze-code.config")
local commands = require("freeze-code.commands")
local u = require("freeze-code.utils")
local logger = u.logger
local FreezeBinary = {}

---@class FreezeBinary
---@field freeze function: Running `freeze` function
---Freeze file with a range or current buffer if no range is given
---@param s_line? number: line to start range
---@param e_line? number: line to start range
function FreezeBinary:freeze(s_line, e_line)
  if not cfg.config._installed then
    logger.warn("[freeze-code.nvim] `freeze` not installed")
    binary_fetcher:install_freeze(cfg.config)
    return
  end

  s_line = s_line or 1
  e_line = e_line or vim.api.nvim_buf_line_count(vim.api.nvim_get_current_buf())

  local cmd = cfg.config.freeze_path

  if not u.check_executable("freeze", cmd) then
    return
  end

  local lang = ""
  if vim.fn.has("nvim-0.10") == 1 then
    lang = vim.api.nvim_get_option_value("filetype", { buf = vim.api.nvim_get_current_buf() })
  else
    ---@diagnostic disable-next-line: deprecated
    lang = vim.api.nvim_buf_get_option(vim.api.nvim_get_current_buf(), "filetype")
  end
  local file = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  local conf = cfg.config.freeze_config.config
  local dir = cfg.config.dir
  local theme = cfg.config.freeze_config.theme
  local output = cfg.config.freeze_config.output

  if output ~= "freeze" then
    local t_stamp = os.date("%Y%m%d%H%M%S")
    local filename = file:match("^.+/(.*)$") or file

    output = string.format("%s_%s_%s", tostring(t_stamp), filename, output)
  end

  cfg.config.output = dir .. "/" .. output .. ".png"

  local cmd_args = {
    "--output",
    cfg.config.output,
    "--language",
    lang,
    "--lines",
    s_line .. "," .. e_line,
    "--config",
    conf,
    file,
  }
  if conf == "base" or conf == "full" then
    vim.list_extend(cmd_args, {
      "--theme",
      theme,
    })
  end

  commands.job = {}
  commands.job.stdout = vim.loop.new_pipe(false)
  commands.job.stderr = vim.loop.new_pipe(false)

  local job_opts = {
    args = cmd_args,
    stdio = { nil, commands.job.stdout, commands.job.stderr },
  }

  local msg = "🍧 frozen frame in path=" .. cfg.config.output
  commands.job.handle = vim.loop.spawn(cmd, job_opts, commands.on_exit(msg))
  vim.loop.read_start(commands.job.stdout, vim.schedule_wrap(commands.on_output))
  vim.loop.read_start(commands.job.stderr, vim.schedule_wrap(commands.on_output))
end

---@class FreezeBinary
---@field freeze_line function: Running `freeze` function for current line
---Freeze file with a range or current buffer if no range is given
function FreezeBinary:freeze_line()
  local curent_line = vim.api.nvim_win_get_cursor(0)[1]
  self:freeze(curent_line, curent_line)
end

return FreezeBinary
