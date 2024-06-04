---@meta

local api = require("freeze-code.utils.api")
local cfg = require("freeze-code.config")

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
---@field setup function: setup function for `freeze-code.nvim`
---freeze-code's set up function
---@param opts FreezeCodeConfig|nil
freeze_code.setup = function(opts)
  cfg.setup(opts)
  create_autocmds()
end

return freeze_code
