-- TODO: Rework and make into a proper module
_G.AUTOFORMAT = false            -- Global to track if we want autoformatting to be enabled
function autoformatting_status() -- Check if current buffer has formatting
  local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
  clients = vim.tbl_filter(function(client)
    return client.supports_method('textDocument/formatting')
  end, clients)

  if #clients > 0 then
    if _G.AUTOFORMAT then     -- Autoformatting enabled
      return 1
    else                      -- Autoformatting disabled, but available
      return 0
    end
  else   -- Autoformatting not available
    return -1
  end
end

-- Setting and running autoformatting
local function set_autoformat(opts)
  local set = opts.set

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

vim.api.nvim_create_user_command('LspAutoFormat', set_autoformat, { nargs = '?' })
vim.cmd [[autocmd BufWritePre * lua if _G.AUTOFORMAT then vim.lsp.buf.format() end]] -- Autoformat on save
