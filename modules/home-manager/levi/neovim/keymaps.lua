-- NOTE TO FUTURE SELF: keybinds will expand named keys, which means that if
-- you are mapping commands that also use these then they might not play nice
-- together, e.g. if you `:map xy :normal! ggv/\S<CR>`, then <CR> will "finish"
-- the normal command, and since the search command must be finished by its own
-- <CR> it will be left unfinished and thus aborted. Instead, in these cases,
-- consider using :exec.

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

-- Custom "text object" that selects all text in buffer 
-- i will exclude blank characters at begining or end of buffer, a selects all in buffer.keykey
vim.keymap.set({'v', 'o'}, 'ia', select_all_inner, { silent = true, desc = 'Select [Inner] [A]ll' })
vim.keymap.set({'v', 'o'}, 'aa', ':<C-u>normal! gg0vG$<CR>', { silent = true, desc = 'Select [All] [A]ll' })

vim.keymap.set('n', '<leader>cpe', copilot_enable, { desc = '[C]o[P]ilot [E]nable' })
vim.keymap.set('n', '<leader>cpd', require('copilot.command').disable, { desc = '[C]o[P]ilot [D]isable' })
vim.keymap.set('n', '<leader>cps', require('copilot.command').status, { desc = '[C]o[P]ilot [S]tatus' })
