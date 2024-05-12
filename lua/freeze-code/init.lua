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
---@field output string|nil: output filename

---@type FreezeConfig
local freeze_config = {
  output = "freeze",
  config = "base",
  theme = "default",
}

---@type FreezeCodeConfig
local config = {
  freeze_path = vim.fn.exepath("freeze"),
  copy_cmd = vim.env.HOME .. "/dev/nvim_plugins/freeze-code.nvim/bin/pngcopy-macos",
  copy = false,
  open = false,
  dir = vim.env.PWD,
  freeze_config = freeze_config,
  output = nil,
}

---@class FreezeCode
---@field setup function
---@field config FreezeCodeConfig
---@field freeze function: Running `freeze` function
---@field copy function: Copying image to clipboard

---@type FreezeCode|{}
local freeze_code = {}

local commands = require("freeze-code.commands")

freeze_code.config = config

freeze_code.copy = function(opts)
  commands.copy(opts)
end

---Freeze file with a range
---@param s_line? number: line to start range
---@param e_line? number: line to start range
freeze_code.freeze = function(s_line, e_line)
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

local create_autocmds = function()
  vim.api.nvim_create_user_command("Freeze", function(opts)
    vim.api.nvim_out_write("[freeze-code] Freeze called")
    if opts.count > 0 then
      freeze_code.freeze(opts.line1, opts.line2)
    else
      freeze_code.freeze()
    end
  end, {
    range = true,
  })
end

---freeze-code's set up function
---@param opts {}|nil
freeze_code.setup = function(opts)
  freeze_code.config = vim.tbl_deep_extend("force", {}, freeze_code.config, opts or {})
  create_autocmds()
end

return freeze_code
