-- Open new buffer relative to current buffer via :Re <filename>
vim.api.nvim_create_user_command('Re', [[execute "edit" expand('%:h') .. fnameescape('/<args>')]], { nargs = 1 })
