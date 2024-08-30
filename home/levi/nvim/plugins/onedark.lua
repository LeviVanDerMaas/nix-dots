require('onedark').setup {
    style = 'deep',
    toggle_style_key = '<leader>tt',
    highlights = {
        -- If these overrides do not seem to work, place cursor on item,
        -- wait for syntax highlights, then use :Inspect to see where highlights are from.

        ["ModeMsg"] = { fmt = "bold", fg = "$fg" },
        ["@operator"] = { fg = "$cyan" },
    }
}
