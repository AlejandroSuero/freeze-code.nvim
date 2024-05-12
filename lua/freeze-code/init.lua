---@class FreezeConfig
---@field output string|"freeze.png": Freeze output filename `--output "freeze.png"`
---@field theme string|"default": Freeze theme `--theme "default"`
---@field config string|"base": Freeze configuration `--config "base"`

---@class FreezeCodeConfig
---@field freeze_path string: Path to `freeze` executable
---@field copy_cmd string: Path to copy `image/png` to clipboard command
---@field copy boolean: Open image after creation option
---@field open boolean: Open image after creation option
---@field dir string: Directory to create image
---@field freeze_config FreezeConfig

---@class FreezeCode
---@field setup function
---@field config FreezeCodeConfig

---@type FreezeCode|{}
local freeze_code = {}

---@type FreezeConfig
local freeze_config = {
  output = "freeze.png",
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
}

freeze_code.config = config

---freeze-code's set up function
---@param opts {}|nil
freeze_code.setup = function(opts)
  freeze_code.config = vim.tbl_extend("force", {}, freeze_code.config, opts or {})
end

return freeze_code
