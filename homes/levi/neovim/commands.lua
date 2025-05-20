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
