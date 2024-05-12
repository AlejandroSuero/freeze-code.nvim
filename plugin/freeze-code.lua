if vim.fn.has("nvim-0.9.0") ~= 1 then
  vim.api.nvim_err_writeln("[freeze-code] plugin requires at least NeoVim 0.9.0.")
  return
end

-- Check if plugin is loaded
if vim.g.loaded_freeze_code == 1 then
  return
end
vim.g.loaded_freeze_code = 1
vim.api.nvim_out_write("[freeze-code] initialized")

vim.api.nvim_create_user_command("Freeze", function(opts)
  local freeze_cmd = require("freeze-code")
  vim.api.nvim_out_write("[freeze-code] Freeze called")
  if opts.count > 0 then
    freeze_cmd.freeze(opts.line1, opts.line2)
  else
    freeze_cmd.freeze()
  end
end, {
  range = true,
})
