-- This file sets up the LSP configuration, which includes
-- mason.nvim
-- mason.lspconfig.nvim
-- nvim-lspconfig.nvim
-- The plugins need to be set up in that order.
-- Confirm LSP installation with either `:LspLog` or `:LspInfo`
-- `:LspInfo` shows the status of active and configured language servers.

-- # To add a language
-- 1. Add LSP in `mason-lspconfig.nvim` `ensure_installed`
-- 2. Call setup for LSP in `neovim/nvim-lspconfig`
-- 3. Install language in Treesitter (seperate file)
-- 4. Install any linters and formatters (seperate file)
-- 5. Quit and reopen nvim

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "williamboman/mason.nvim", config = true },
    "williamboman/mason-lspconfig.nvim",
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("dg1234uk-lsp-attach", { clear = true }),
      callback = function(event)
        -- keymaps
        -- TODO: Add keymaps
        vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})

        -- TODO: Look at the other autocmds in kickstarter project
        -- Will need to add `event` as a an argument to callback function
      end,
    })

    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls",
      },
    })
    require("mason-lspconfig").setup({})

    local lspconfig = require("lspconfig")
    -- Set up each installed language server
    lspconfig.lua_ls.setup({
      settings = {
        Lua = {
          completion = {
            callSnippet = "Replace",
          },
        },
      },
    })
  end,
}
