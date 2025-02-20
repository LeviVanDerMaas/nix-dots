local autoformat_str = function()
    local status = autoformatting_status()
    if status == 1 then
        return '[AF]'
    elseif status == 0 then
        return '[F]'
    elseif status == -1 then
        return ''
    end
end

local buffer_status = function()
    local readonly = vim.bo.readonly and '[RO] ' or ''
    local modified = vim.bo.modified and '[+] ' or ''
    local nonmodifiable = (not vim.bo.modifiable) and '[-] ' or ''
    local otherBufModified = check_other_buf_modifed() and '[*] ' or ''
    return readonly .. nonmodifiable .. modified .. otherBufModified
end

require('lualine').setup {
    options = {
        component_separators = '│',
        section_separators = '',
    },
    sections = {
        lualine_a = { 'mode', 'selectioncount' },
        lualine_b = {
            { 'filename', file_status = false },
        },
        lualine_c = { buffer_status },
        lualine_x = { autoformat_str },
        lualine_y = {
            'diagnostics',
            { 'diff', separator = '' },
            'branch',
        },
        lualine_z = { 'location' }
    },
}
