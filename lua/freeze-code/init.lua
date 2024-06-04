---@meta

local api = require("freeze-code.utils.api")
local cfg = require("freeze-code.config")
local deprecate = require("freeze-code.deprecated")

---@class FreezeCode
local freeze_code = {}

local create_autocmds = function()
  vim.api.nvim_create_user_command("Freeze", function(opts)
    if opts.count > 0 then
      api.freeze(opts.line1, opts.line2)
    else
      api.freeze()
    end
  end, {
    range = true,
  })
  vim.api.nvim_create_user_command("FreezeLine", function(_)
    api.freeze_line()
  end, {})
end

---@class FreezeCode
---@field freeze function: freezes the current buffer
freeze_code.freeze = function(_line1, _line2)
  deprecate.command("require('freeze-code').freeze", "Now using `require('freeze-code.utils.api').freeze`")
end

---@class FreezeCode
---@field freeze_line function: freezes the current line
freeze_code.freeze_line = function()
  deprecate.command("require('freeze-code').freeze_line", "Now using `require('freeze-code.utils.api').freeze_line`")
end

---@class FreezeCode
---@field setup function: setup function for `freeze-code.nvim`
---freeze-code's set up function
---@param opts FreezeCodeConfig|nil
freeze_code.setup = function(opts)
  cfg.setup(opts)
  create_autocmds()
end

return freeze_code
