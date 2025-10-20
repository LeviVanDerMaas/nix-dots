local o = vim.opt

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
o.expandtab = true -- May be afffected by vimsleuth plugin
o.shiftwidth = 4 -- May be affected by vimsleuth plugin
o.softtabstop = -1 -- Negative causes it to follow shiftwidth

-- Patterns & Searching
o.hlsearch = true
o.incsearch = true
o.ignorecase = true
o.smartcase = true

-- UI
o.termguicolors = true
o.number = true
o.relativenumber = true
o.list = true
o.listchars = 'tab:▸ ,trail:·,nbsp:⍽,extends:❯,precedes:❮,'
o.wrap = false
o.breakindent = true
o.linebreak = true
o.signcolumn = 'yes'
o.colorcolumn = '+1'
o.scrolloff = 8
o.sidescrolloff = 9
