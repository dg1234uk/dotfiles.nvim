-- This file installs autocomplete, with snippets
-- For this we need
-- `nvim-cmp` - completion engine - does not provide the completion source
-- `luasnip` - snippet expansion tool
-- `cmp.luasnip` - luaSnips completion source for `nvim-cmp`
-- `cmp.nvim.lsp` - LSP completion source for the current buffer
-- `friendly-snippets` - a library of snippets for many languages

return {
  {
    "hrsh7th/cmp-nvim-lsp",
  },
  {
    "hrsh7th/cmp-path",
  },
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp LUAJIT_OSX_PATH=/usr/local/bin",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
  },
  {
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      luasnip.config.set_config({
        enable_autosnippets = true,
        store_selection_keys = "<Tab>",
        update_events = "TextChanged, TextChangedI",
      })
      -- Require snippets from our snippets directory
      local config_path = vim.fn.stdpath("config") .. "/snippets/"
      -- Load VS-Code JSON style snippets
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { config_path .. "/vscode/" } })
      -- Load Lua snippets
      require("luasnip.loaders.from_lua").load({ paths = { config_path .. "/lua/" } })

      cmp.setup({
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
            -- TODO: Look into native neovim snippets
            -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
          end,
        },
        window = {
          -- How the window looks
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          -- ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              if luasnip.expandable() then
                luasnip.expand()
              else
                cmp.confirm({
                  select = true,
                })
              end
            else
              fallback()
            end
          end),

          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
          { name = "luasnip" },
        }, {
          -- TODO: Look into buffer in the nvim-cmp github install docs
          { name = "buffer" },
        }),
      })
    end,
  },
}
