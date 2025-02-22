-- Make sure this is inserted into the global space before whatever needs any of this
-- calls upon it.

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

function character_under_cursor_blank()
    local char = get_character_under_cursor()
    -- Vim defines blank characters as being either Space or Tab.
    -- We also return true for empty lines as the cursor is technically
    -- on a nonblank character.
    return char == "" or char == " " or char == "\t"
end

function select_all_inner()
    -- Select all text in a buffer barring any blanks at the start or end
    -- This is much less trivial to do than selecting all characters in a
    -- buffer, hence it is a seperate 
    vim.cmd[[silent! exec "normal! \e"]] -- Little hack to force normal mode
    vim.cmd [[silent! normal! gg0"]]
    if character_under_cursor_blank() then
        vim.cmd [[silent! exec "normal! /\\S\r"]]
    end
    vim.cmd [[silent! normal! vG$"]]
    if character_under_cursor_blank() then
        vim.cmd [[silent! exec "normal! ?\\S\r"]]
    end
end
