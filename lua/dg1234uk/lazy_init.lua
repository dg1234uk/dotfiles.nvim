-- Install Lazy Plugin Manager
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
---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Plugins to install via lazy
local plugins = {
  { import = "dg1234uk.plugins" },
  -- { import = "dg1234uk.plugins.lsp" },
}

-- Lazy options
local opts = {
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
}

-- Load lazy with our requested plugins and options
require("lazy").setup(plugins, opts)
