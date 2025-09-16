local g = vim.g
local o = vim.opt

-- Vim globals
g.mapleader = ' ' -- WARNING: Set BEFORE loading plugins!
g.maplocalleader = ' ' -- WARNING: Set BEFORE loading plugins!

-- Data
o.swapfile = false -- If true, `updatetime` shouldn't be too low.
o.undofile = true -- By default gets stored in XDG_STATE_HOME/nvim/undo

-- Control Behaviour
o.updatetime = 50 -- Low because Cursurhold autocmd is used to create diagnostics windows
o.clipboard = 'unnamed,unnamedplus' 
o.completeopt = 'menuone,noselect,noinsert,preview'
o.mouse = 'a'

-- Tab & Indent Behaviour
o.autoindent = true
o.smartindent = true
o.softtabstop = 4
o.expandtab = true -- May be afffected by vimsleuth plugin
o.shiftwidth = 4 -- May be affected by vimsleuth plugin


-- UI
o.termguicolors = true
o.number = true
o.relativenumber = true
o.list = true
o.listchars = 'tab:▸ ,nbsp:+,extends:❯,precedes:❮,'
o.wrap = false
o.breakindent = true
o.signcolumn = 'yes'
o.colorcolumn = '+1'
o.scrolloff = 8

-- Patterns & Searching
o.hlsearch = false
o.incsearch = true
o.ignorecase = true
o.smartcase = true
