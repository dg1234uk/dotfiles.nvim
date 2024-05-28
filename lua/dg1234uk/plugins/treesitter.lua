-- Treesitter is used for code syntax highlighting
-- Add required languages to ensure_installed

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local config = require("nvim-treesitter.configs")
    config.setup({
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "lua",
      },
      sync_install = false,
      ignore_install = { "latex" },
    })
  end,
}
