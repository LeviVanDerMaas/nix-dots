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



--====================================== UTIL
-- Autoformatting
_G.AUTOFORMAT = false            -- Global to track if we want autoformatting to be enabled
function autoformatting_status() -- Check if current buffer has formatting
    local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
    clients = vim.tbl_filter(function(client)
        return client.supports_method('textDocument/formatting')
    end, clients)

    if #clients > 0 then
        if _G.AUTOFORMAT then -- Autoformatting enabled
            return 1
        else                  -- Autoformatting disabled, but available
            return 0
        end
    else -- Autoformatting not available
        return -1
    end
end



-- Buffers
function check_other_buf_modifed() -- Check if any buffer other than current is modified
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and buf ~= vim.api.nvim_get_current_buf() and vim.api.nvim_buf_get_option(buf, "modified") then
            return true
        end
    end
    return false
end



-- Content
function get_character_under_cursor()
    local _, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    return string.sub(line, col + 1, col + 1)
end



--====================================== KEYMAPS
-- NOTE: keymaps expand named keys like <CR>, use exec in cases where you need named keys.
vim.keymap.set('', '<leader>h', function ()
  if vim.v.hlsearch == 0 then
    vim.o.hlsearch = true
  else
    vim.v.hlsearch = 0 -- Disable highlights but not 'hlsearch' option
  end
end, { silent = true; desc = 'Toggle search highlights' })
vim.keymap.set('', '<leader>H', ':set hlsearch!<CR>:set hlsearch?<CR>', { desc = "Toggle 'hlsearch' option" })

-- Telescope
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').find_files, { desc = '[ ] search files' })
vim.keymap.set('n', '<leader>/', require('telescope.builtin').current_buffer_fuzzy_find, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sb', require('telescope.builtin').buffers, { desc = '[S]earch [B]uffers' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>vo', require('telescope.builtin').vim_options, { desc = 'Search [V]im [O]ptions' })

-- Copilot
vim.keymap.set('n', '<leader>cpe', copilot_enable, { desc = '[C]o[P]ilot [E]nable' })
vim.keymap.set('n', '<leader>cpd', require('copilot.command').disable, { desc = '[C]o[P]ilot [D]isable' })
vim.keymap.set('n', '<leader>cps', require('copilot.status.init').status, { desc = '[C]o[P]ilot [S]tatus' })

-- Text Objects
-- "i" will exclude blank characters at begining or end of buffer, "a" selects all in buffer
vim.keymap.set({'v', 'o'}, 'ia', function ()
    vim.cmd[[silent! exec "normal! \e"]] -- Little hack to force normal mode
    vim.cmd [[silent! normal! gg0"]]
    vim.call('search', '\\S', 'c') -- To the next non-blank char, including the one the cursor is on
    vim.cmd [[silent! normal! vG$"]]
    vim.call('search', '\\S', 'bc') -- To the previous non-blank char, including the one the cursor is on
end, { silent = true, desc = 'Select [I]nner [A]ll' })
vim.keymap.set({'v', 'o'}, 'aa', [[:<C-u>normal! gg0vG$<CR>]], { silent = true, desc = 'Select [A]ll [A]ll' })



--====================================== commands
-- Open new buffer relative to current buffer via :Re <filename>
vim.cmd [[command -nargs=1 Re execute "edit" expand('%:h') .. fnameescape('/<args>') ]]



-- Setting and running autoformatting
function set_autoformat(set)
    if set == "toggle" then
        _G.AUTOFORMAT = not _G.AUTOFORMAT
    elseif set == "on" then
        _G.AUTOFORMAT = true
    elseif set == "off" then
        _G.AUTOFORMAT = false
    elseif set ~= nil then
        print("AutoFormat: invalid argument, must be 'on', 'off' or 'toggle'")
        return
    end
    local status_string = _G.AUTOFORMAT and 'on ' or 'off '
    local available_string = (autoformatting_status() == -1) and '(UNAVAILABLE) ' or ''
    print("Autoformat via LSP turned " .. status_string .. available_string)
end

vim.cmd [[command -nargs=? AutoFormat lua set_autoformat(<f-args>)]]



vim.cmd [[autocmd BufWritePre * lua if _G.AUTOFORMAT then vim.lsp.buf.format() end]] -- Autoformat on save
