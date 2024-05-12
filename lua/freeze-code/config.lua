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

return config
