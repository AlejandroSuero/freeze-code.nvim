---@meta

---@class FreezeCodeOS
---@field is_win boolean
---@field is_macos boolean
---@field is_unix boolean

---@class FreezeCodeUtils
---@field logger FreezeCodeLogger
---@field os FreezeCodeOS
---@type FreezeCodeUtils|{}
local M = {}

M.logger = require("freeze-code.utils.logger")

M.os = {
  is_win = vim.loop.os_uname().version:match("Windows"),
  is_macos = vim.loop.os_uname().version:match("Darwin"),
  is_unix = vim.loop.os_uname().version:match("Linux"),
}

return M
