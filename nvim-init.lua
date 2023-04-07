require'lualine'.setup{
  options = {
      theme = 'base16'
    }
}

-- Show invisible characters
vim.opt.list = true
vim.opt.listchars = { tab = '› ', trail = '~', extends = '»', precedes = '«', nbsp = '_', }

local signs = {
    { name = 'DiagnosticSignError', text = '🔥' },
    { name = 'DiagnosticSignWarn', text = '⚠️' },
    { name = 'DiagnosticSignHint', text = '💡' },
    { name = 'DiagnosticSignInfo', text = '🔸' },
}

for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

require'nvim-treesitter.configs'.setup{
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true,
    },
}

vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('AutoformatOnWrite', {}),
  callback = function() vim.lsp.buf.formatting_sync(nil, 1000) end
})

require'lspconfig'.rnix.setup{}

require'lspconfig'.hls.setup{
  settings = {
    haskell = {
        formattingProvider = 'fourmolu'
    },
  },
}

require'lspconfig'.clangd.setup{
    cmd = {
        'clangd',
        '--background-index',
        '--inlay-hints',
        '--clang-tidy',
        '--compile-commands-dir=build',
    },
}

require 'nvim-tree'.setup {
    open_on_setup = true,
    open_on_setup_file = true,
    open_on_tab = true,
    update_focused_file = {
        enable = true,
    },
}

require'gitsigns'.setup{}

-- Automatically close the tab/vim when nvim-tree is the last window in the tab
vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('CloseNvimTreeWhenLast', {}),
    command = "if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif",
    nested = true,
})

-- Setup Completion
-- See https://github.com/hrsh7th/nvim-cmp#basic-configuration
local cmp = require'cmp'

cmp.setup({
  -- Enable LSP snippets
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    -- Add tab support
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    })
  },

  -- Installed sources
  sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'path' },
    { name = 'buffer' },
    { name = 'treesitter' },
  },
})
