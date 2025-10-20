local cmp = require 'cmp'
local luasnip = require 'luasnip'
local lspkind = require 'lspkind'

-- Put the setup and enabling of copilot in a callable function
-- (that will also reenable copilot if it was disabled after setup
-- was already done). This lets us
-- 1. Effectively lazy load copilot (as recommended in the README).
-- 2. Keep copilot disabled until actually needed (since the
--    setup will enable it by default with no way to prevent this).
function copilot_enable()
  -- Checking the source code shows copilot is smart enough to
  -- check if setup is already done and if so return immediately
  require("copilot").setup({
    suggestion = { enabled = false },
    panel = { enabled = false },
  })
  require("copilot.command").enable()
end

-- Call this even if copilot was not yet set up,
-- as otherwise we cannot register copilot as a cmp source.
require("copilot_cmp").setup()


local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

-- A custom nvim-cmp comperator that will always favour non copilot entries.
local sortcompare_copilot_deprioritize = function(entry1, entry2)
  if entry1.copilot and not entry2.copilot then
    return false
  elseif entry2.copilot and not entry1.copilot then
    return true
  elseif entry1.copilot and entry2.copilot then
    return false
  end
  return nil
end

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    -- Add tab support
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() and has_words_before() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-f>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping(function(fallback)
      if cmp.visible() and cmp.get_active_entry() then
        cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
      else
        fallback()
      end
    end
    ),
  }),
  sources = cmp.config.sources({
    -- Allegdly the order of these also affects certain calculations
    -- when sorting the entries (such as their priority)
    { name = 'path' },                      -- file paths
    { name = 'nvim_lsp' },                  -- from language server
    { name = 'nvim_lsp_signature_help' },   -- display function signatures with current parameter emphasized
    { name = 'luasnip' },
    { name = 'nvim_lua' },                  -- complete neovim's Lua runtime API such vim.lsp.*
    { name = 'buffer' },                    -- source current buffer
    { name = 'calc' },                      -- source for math calculation

    -- Put copilot at bottom to lower its priority
    { name = "copilot" },
  }),
  sorting = {
    priority_weight = 2,
    comparators = {
      -- If a comperator returns true then the first element comes first,
      -- false the second element comes first, and if nil then it tries
      -- the next comperator. Below is the default comparitor list and
      -- order for nvim-cmp. The cmp default is, in order: offset,
      -- exact, score, recently used, locality, kind, sort_text, length,
      -- order.
      --
      -- The source code comments for most of thedse defaults explains what
      -- they do in a way that isn't too vague, but interestingly the three
      -- highest ones (offset, exact, score) are very vague eventhough they
      -- are the most commonly used ones. It does not help that these heavily
      -- rely on properties of each entry that are computed across multiple source
      -- files. From my understanding of reading the source code:
      --  * I think offset is at what point an entry actually starts to match
      --    some of the already typed text (maybe comperatively to other entries?)
      --    e.g. for "table.fi" the entry "fiield" has a lower offset then "has_field()"
      --    because the fi appears earlier. This aligns with what the plugin
      --    maintainer says https://github.com/hrsh7th/nvim-cmp/issues/883.
      --  * The exactness of an entry is simply wheter it matches the candidate to be completed
      --    or not (and this also considers offset). The exact comperator will prefer one entry
      --    over the other if one of them is exact while the other one isn't.
      --  * I am not sure what score does, it seems to be a more complex calculation based
      --    on various metrics that breaks a tie in most cases.
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.locality,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text',
      maxwidth = 50,     -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      -- can also be a function to dynamically calculate max width such as
      -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
      ellipsis_char = '...',        -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
      show_labelDetails = true,     -- show labelDetails in menu. Disabled by default

      symbol_map = { Copilot = "" },

      -- The function below will be called before any actual modifications from lspkind
      -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
      before = function(entry, vim_item)
        -- Currently don't do anything
        return vim_item
      end
    })
  },
})

cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' },   -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})
