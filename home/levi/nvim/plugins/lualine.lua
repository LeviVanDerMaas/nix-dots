local function check_other_buf_modifed() -- Check if any buffer other than current is modified
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and buf ~= vim.api.nvim_get_current_buf() and vim.api.nvim_buf_get_option(buf, "modified") then
            return true
        end
    end
    return false
end

-- Custom lualine component to show modified and readonly status
local buffer_status = function()
    local readonly = vim.bo.readonly and '[RO] ' or ''
    local modified = vim.bo.modified and '[+] ' or ''
    local nonmodifiable = true and '[-] '
    local otherBufModified = true and '[*] ' or ''
    return readonly .. modified  .. nonmodifiable  .. otherBufModified
end

require('lualine').setup {
    options = {
        component_separators = '|',
        section_separators = '',
    },
    sections = {
        lualine_a = { 'mode', 'selectioncount' },
        lualine_b = { 
            { 'filename', file_status = false },
        },
        lualine_c = { buffer_status },
        lualine_x = { 'diagnostics' },
        lualine_y = {
            { 'diff', separator = '' },
            'branch' ,
        },
        lualine_z = { 'location' }
    },
}
