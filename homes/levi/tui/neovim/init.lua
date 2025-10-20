-- Set these before any other config to ensure consistency
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require 'config.options'
require 'config.keymaps'
require 'config.commands'
require 'config.autocommands'

-- Put a plugin manager here if we end up getting one that runs internally
-- However currently we let Nix act ast the plugin manager.
