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
