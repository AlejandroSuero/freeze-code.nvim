local deprecated = {}

deprecated.command = function(command, message)
  local messages = {}
  table.insert(
    messages,
    "Deprecated command: "
      .. command
      .. "\n"
      .. message
      .. ".\nPlease use :help freeze-code.nvim.txt for more information."
  )
  vim.api.nvim_err_write(
    string.format("[freeze-code.nvim] %s", table.concat(messages, "\n \n  ") .. "\n \nPress <Enter> to continue.\n")
  )
end

deprecated.options = function(opts)
  local messages = {}
  table.insert(
    messages,
    "Deprecated options:\n" .. vim.inspect(opts) .. ".\nPlease use :help freeze-code.nvim.txt for more information."
  )
  vim.api.nvim_err_write(
    string.format("[freeze-code.nvim] %s", table.concat(messages, "\n \n  ") .. "\n \nPress <Enter> to continue.\n")
  )
end

return deprecated
