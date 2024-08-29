require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                ['<C-u>'] = false,
                ['<C-d>'] = false,
            },
        },
    },
}

require("telescope").load_extension("ui-select")
pcall(require('telescope').load_extension, 'fzf')
