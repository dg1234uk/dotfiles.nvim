# NeoVim Setup notes

## `init.lua`

```lua
-- Vim Options
vim.g.mapleader = " "
vim.cmd( "set expandtab" )
vim.cmd( "set tabstop=2" )
vim.cmd( "set softtabestop=2" )
vim.cmd( "set shiftwidth=2" )

-- Lazy Package manager install
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- set up table of plugins and options then get NeoVim to load lazy
-- Plugins to install
local plugins = {
  {"catppuccin/nvim", name="catppuccin", priority = 1000},
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.6',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
}

-- Lazy options
local opts = {}

-- Load lazy and install plugins
require("lazy").setup(plugins, opts)

-- require and setup installed plugins
require("catppuccin").setup()
vim.cmd.colorscheme "catppuccin"

-- Telescope setup
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})

-- Treesitter setup
local config = require("nvim-treesitter.configs")
config.setup({
  ensure_installed = {"lua", "javascript"},
  highlight = { enabled = true },
  indent = { enabled = true },
})
```

## Modularise the setup

We can take the plugin loading and setup and place them into their own files:

```lua
-- plugins/catppuccin.lua

return {
  "catppuccin/nvim",
  name="catppuccin",
  priority = 1000
  config = function()
    vim.cmd.colorscheme "catppuccin"
  end
}
```

The file must return a lua table, this includes the plugin install section from the previous `plugin` variable and any plugin setup. However, the setup now goes into the `config` property which should be a callback function that gets called once the plugin is loaded. And doesn't need `require()` calls.

We also need to modify the Lazy config to take account for the new location of plugins `require("lazy").setup("plugins")`

We can also split the vim options out to a separate file, use `require("options")` in your main `init.lua` to include this.

## LSP

We need to:

1. Install language servers
2. Configure NeoVim to talk to these language servers

### Install language servers

For this use Mason:

```lua
return {
  "williamboman/mason.nvim",
  config = function()
    require("mason").setup
  end
}
```

Place all in `lsp-config.lua`. Once Mason is installed you can use the command `:Mason` to see its interface.

Next we use `mason-lspconfig.nvim` to bridge the gap between Mason and the `lspconfig` plugin (which we will also install). `mason-lspconfig.nvim` can be used to specify `ensure_installed` to ensure your required language servers have been installed.

To install `mason-lspconfig.nvim` we will add it to the table of plugins we will return from our single `lsp-config.lua` file.

```lua
-- plugins/lsp-config.lua

return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup
    end
  },
  {
    "williamboman/mason-lspconfig.nvim"
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {"lua_ls"} -- LSPs to install
      })
    end
  }
}
```

To hook up the installed language server to NeoVim we need `nvim-lspconfig`. We can use this plugin to also setup NeoVim keybinds to use the feature of our LSP.

```lua
-- plugins/lsp-config.lua
return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup
    end
  },
  {
    "williamboman/mason-lspconfig.nvim"
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {"lua_ls"} -- LSPs to install
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      -- We have to set up each installed language server, here we only have Lua
      lspconfig.lua_ls.setup({})

      -- keymaps
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', 'gd' vim.lsp.buf.definition, {})
      vim.keymap.set('n', '<leader>ca' vim.lsp.buf.code_action, {})
    end
  }
}
```

To confirm your LSP is installed correctly type `:LspInfo` which will give information about the LSPs connected to your current buffer. You can see what functions are available for buffers to use / keymap by going to `:h vim.lsp.buf`

#### Adding extra servers

Follow these steps:

1. Add LSP in `mason-lspconfig.nvim` `ensure_installed`
2. Call setup for LSP in `neovim/nvim-lspconfig`
3. Quit and reopen nvim.

#### Extra Credit - `telescope-ui-select`

Will give a better UI to selects, such as code actions.

Add to the `telescope.lua` plugin

```lua
-- plugins/telescope.lua
return {
  {
    "nvim-telescope/telescope-ui-select.nvim",
  },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<C-p>", builtin.find_files, {})
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
      vim.keymap.set("n", "<leader><leader>", builtin.oldfiles, {})

      require("telescope").load_extension("ui-select")
    end,
  },
}
```

## Linting, Formatting

Used to `null-ls` it would wrap general command line (i.e. eslint, prettier, etc.) tools into an LSP so it could then be used by your LSP setup. Here we use `none-ls` which is a fork of `null-ls`. Then you can call LSP functions to access the functionality of that tool.

```lua
-- plugins/none-ls.lua

return {
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      -- Set up
      sources = {
        null_ls.builtins.formatting.stylua, -- lua formatter, you have to ensure this is installed via Mason
        null_ls.builtins.diagnostics.eslint_d, -- Javascript + TS linter, install via mason
        null_ls.builtins.formatting.prettier, -- Javascript + more, install via mason
      }
    })

    -- keymaps
    vim.keymap.set('n', '<leader>gf', vim.lsp.buf.format, {})
  end
}
```

Note: `eslint_d` is a daemon version of `eslint`. This will always be running in the background with NeoVim, and thus saves startup time for each lint compared with just running the `eslint` command line tool.

## Autocompletion & Snippets

- `nvim-cmp` engine for completions - does not provide the actual completion soruce
- `luasnip` snippet expansion tool
- `cmp.luasnip` luaSnips completeion source for `nvim-cmp`
- `cmp.nvim.lsp` provides the source for LSP completions for current buffer
- `friendly-snippets` a library of snippets for many languages

```lua
-- plugins/completions.lua

return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    }
  },
  {
  "hrsh7th/nvim-cmp",
  config = function()
    local cmp = require'cmp'
    require("luasnip.loaders.from_vscode").lazy_load()

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
      end,
    },
    window = {
        -- How the window looks
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      -- { name = 'nvim_lsp' }, -- Will cover this in a minute
      { name = 'luasnip' }, -- For luasnip users.
    }, {
      { name = 'buffer' },
    })
  })

    })
  end
  },
}
```

### Add LSP completions

Add the following to the top of `plugins/completions.lua`

```lua
  {
    "hrsh7th/cmp-nvim-lsp",
  },
```

Next we have to tell our LSP about this, in `plugins/lsp-config.lua`

```lua
-- plugins/lsp-config.lua
return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup
    end
  },
  {
    "williamboman/mason-lspconfig.nvim"
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {"lua_ls"} -- LSPs to install
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")

      -- This line is to link up LSP completions with our completion engine.
      -- We then have to set this for each server below
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- We have to set up each installed language server, here we only have Lua
      lspconfig.lua_ls.setup({
        -- Set capabilities for LSP completions
        capabilities = capabilities
      })

      -- keymaps
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', 'gd' vim.lsp.buf.definition, {})
      vim.keymap.set('n', '<leader>ca' vim.lsp.buf.code_action, {})
    end
  }
}
```

## Debuggers

'nvim-dap'

for UI
'nvim-dap-ui'

Install a debug adapter via brew, follow instructions, then install nvim-dap- package for language debugger.

## Github CoPilot

```lua
return {
  "github/copilot.vim"
}
```

Then run `:Copilot setup`
