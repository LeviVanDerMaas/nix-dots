-- NOTE TO FUTURE SELF: keybinds will expand named keys, which means that if
-- you are mapping commands that also use these then they might not play nice
-- together, e.g. if you `:map xy :normal! ggv/\S<CR>`, then <CR> will "finish"
-- the normal command, and since the search command must be finished by its own
-- <CR> it will be left unfinished and thus aborted. Instead, in these cases,
-- consider using :exec.

-- General
vim.keymap.set('', '<leader>h', ':set hlsearch!<CR>', { desc = 'Toggle search [h]ighlights' })
vim.keymap.set('', '<leader>H', ':noh<CR>', { desc = 'No search [h]ighlights' })

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
