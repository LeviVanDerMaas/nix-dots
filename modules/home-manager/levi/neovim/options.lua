-- Data
vim.opt.swapfile = false -- If true, `updatetime` shouldn't be too low.
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.cache/nvim/undo')

-- Control Behaviour
vim.g.mapleader = ' ' -- Set BEFORE loading plugins!
vim.opt.updatetime = 50 -- Low because Cursurhold autocmd is used to create diagnostics windows
vim.opt.clipboard = 'unnamed,unnamedplus' 
vim.opt.completeopt = 'menuone,noselect,noinsert,preview'
vim.opt.mouse = 'a'

-- Tab & Indent Behaviour
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.softtabstop = 4
vim.opt.expandtab = true -- May be afffected by vimsleuth plugin
vim.opt.shiftwidth = 4 -- May be affected by vimsleuth plugin


-- UI
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.list = true
vim.opt.listchars = 'tab:▸ ,nbsp:+,extends:❯,precedes:❮,'
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.signcolumn = 'yes'
vim.opt.colorcolumn = '+1'
vim.opt.scrolloff = 8

-- Patterns & Searching
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
