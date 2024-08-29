require('telescope').setup {
    defaults = {
        mappings = {
            i = {
            },
        },
    },
}

require("telescope").load_extension("ui-select")
pcall(require('telescope').load_extension, 'fzf')
