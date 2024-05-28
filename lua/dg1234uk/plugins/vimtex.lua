return {
  "lervag/vimtex",
  lazy = false, -- we don't want to lazy load VimTeX
  init = function()
    -- VimTeX configuration goes here
    vim.g.vimtex_view_method = "skim"
  end,
}
