-- Create Python 3 venv and install pynvim if it is not already installed.
if vim.fn.empty(vim.fn.glob(vim.fn.stdpath("data") .. "/venv")) == 1 then
  vim.fn.system({
    "python3",
    "-m",
    "venv",
    vim.fn.stdpath("data") .. "/venv",
  })
  vim.fn.system({
    vim.fn.stdpath("data") .. "/venv/bin/python3",
    "-m",
    "pip",
    "install",
    "pynvim",
  })
end
vim.g.python3_host_prog = vim.fn.stdpath("data") .. "/venv/bin/python3"

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
