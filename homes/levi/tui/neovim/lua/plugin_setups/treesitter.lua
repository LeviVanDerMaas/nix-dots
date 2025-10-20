require('nvim-treesitter.configs').setup {
  ignore_install = { "latex" },

  ensure_installed = {},

  auto_install = false,

  highlight = {
    enable = true,
    disable = { "latex" },
  },

  indent = { enable = true },
}
