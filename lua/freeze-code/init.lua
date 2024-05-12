---@class FreezeCode
---@field setup function
---@field config FreezeCodeConfig
---@field freeze function: Running `freeze` function

---@type FreezeCode|{}
local freeze_code = {}

freeze_code.config = require("freeze-code.config")
freeze_code.freeze = require("freeze-code.commands").freeze

---freeze-code's set up function
---@param opts {}|nil
freeze_code.setup = function(opts)
  freeze_code.config = require("freeze-code.config")
  freeze_code.config = vim.tbl_extend("force", {}, freeze_code.config, opts or {})
end

return freeze_code
