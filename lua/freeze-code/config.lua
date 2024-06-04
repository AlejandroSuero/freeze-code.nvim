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

---@type FreezeCodeConfig
local default_config = {
  freeze_config = {
    output = "freeze",
    config = "base",
    theme = "default",
  },
  _installed = vim.fn.exepath("freeze") ~= "",
  install_path = vim.env.HOME .. "/.local/bin",
  freeze_path = vim.fn.exepath("freeze"),
  copy_cmd = vim.env.HOME .. "/dev/nvim_plugins/freeze-code.nvim/bin/pngcopy-macos",
  copy = false,
  open = false,
  dir = vim.env.PWD,
  output = nil,
}

local M = {
  config = vim.deepcopy(default_config),
}

M.setup = function(opts)
  M.config = vim.tbl_deep_extend("force", vim.deepcopy(default_config), opts or {})
end

return setmetatable(M, {
  __index = function(_, key)
    if key == "setup" then
      return M.setup
    end
    return rawget(M.config, key)
  end,
})
