---@meta

---@class FreezeCodeOS
---@field is_win boolean
---@field is_macos boolean
---@field is_unix boolean

---@class FreezeCodeUtils
---@field logger FreezeCodeLogger
---@fiels os FreezeCodeOS
---@type FreezeCodeUtils|{}
local M = {}

M.logger = require("freeze-code.utils.logger")

M.os = {
  is_win = vim.api.nvim_call_function("has", { "win32" }) == 1,
  is_macos = vim.api.nvim_call_function("has", { "macunix" }) == 1,
  is_unix = vim.api.nvim_call_function("has", { "unix" }) == 1,
}

return M
