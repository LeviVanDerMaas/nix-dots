-- Open new buffer relative to current buffer via :Re <filename>
vim.cmd [[command -nargs=1 Re execute "edit" expand('%:h') .. fnameescape('/<args>') ]]

-- Setting and running autoformatting
function set_autoformat(set)
    if set == "toggle" then
        _G.autoformat = not _G.autoformat
    elseif set == "on" then
        _G.autoformat = true
    elseif set == "off" then
        _G.autoformat = false
    elseif set == "?" then

    else
        print("AutoFormat: Invalid argument. Must be 'on', 'off', 'toggle', or '?'")
        return
    end
    local status_string = _G.autoformat and 'on ' or 'off '
    local available_string = (autoformatting_status() == -1) and '(UNAVAILABLE) ' or ''
    print("Autoformat via LSP turned " .. status_string .. available_string)
end

vim.cmd [[command -nargs=1 AutoFormat lua set_autoformat(<f-args>)]]
vim.cmd [[autocmd BufWritePre * lua if _G.autoformat then vim.lsp.buf.format() end]] -- Autoformat on save
