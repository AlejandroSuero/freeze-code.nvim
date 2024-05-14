---@meta

---@brief [[
--- Provides `logging` functions to display messages.
---@brief ]]

---@class FreezeCodeLogger
---@field err function
---@field err_once function
---@field warn function
---@field info function
---@field err_fmt function
---@field err_once_fmt function
---@field warn_fmt function
---@field info_fmt function
---@type FreezeCodeLogger|{}
local M = {}

---Display error message
---@param msg string: Message to display
function M.err(msg)
  vim.notify(msg .. "\n", vim.log.levels.ERROR, { title = "FreezeCode" })
end

---Display error message once
---@param msg string: Message to display
function M.err_once(msg)
  vim.notify_once(msg .. "\n", vim.log.levels.ERROR, { title = "FreezeCode" })
end

---Display warn message
---@param msg string: Message to display
function M.warn(msg)
  vim.notify(msg .. "\n", vim.log.levels.WARN, { title = "FreezeCode" })
end

---Display log message
---@param msg string: Message to display
function M.info(msg)
  vim.notify(msg .. "\n", vim.log.levels.INFO, { title = "FreezeCode" })
end

---Display formatted error message
---@param msg string|number: Format to display
---@param ... any: Format parameters
function M.err_fmt(msg, ...)
  vim.notify(string.format(msg .. "\n", ...), vim.log.levels.ERROR, { title = "FreezeCode" })
end

---Display formatted error message once
---@param msg string|number: Format to display
---@param ... any: Format parameters
function M.err_once_fmt(msg, ...)
  vim.notify_once(string.format(msg .. "\n", ...), vim.log.levels.ERROR, { title = "FreezeCode" })
end

---Display formatted warn message
---@param msg string|number: Format to display
---@param ... any: Format parameters
function M.warn_fmt(msg, ...)
  vim.notify(string.format(msg .. "\n", ...), vim.log.levels.WARN, { title = "FreezeCode" })
end

---Display formatted log message
---@param msg string|number: Format to display
---@param ... any: Format parameters
function M.info_fmt(msg, ...)
  vim.notify(string.format(msg .. "\n", ...), vim.log.levels.INFO, { title = "FreezeCode" })
end

return M
