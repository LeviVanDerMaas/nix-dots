-- Open new buffer relative to current buffer via :Re <filename>
vim.cmd [[command -nargs=1 Re execute "edit" expand('%:h') .. fnameescape('/<args>') ]]

-- Apply lsp formatting
vim.cmd [[command LspFormat lua vim.lsp.buf.format()]]
