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
