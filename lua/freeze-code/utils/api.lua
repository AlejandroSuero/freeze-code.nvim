local binary = require("freeze-code.binary.binary_handler")
local M = {}

M.freeze = function(start_line, end_line)
  binary:freeze(start_line, end_line)
end

M.freeze_line = function()
  binary:freeze_line()
end

return M
