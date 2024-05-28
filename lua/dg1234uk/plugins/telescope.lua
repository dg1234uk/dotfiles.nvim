return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({})
    telescope.load_extension("fzf")

    -- TODO: Add more dependcies and plugins

    local builtin = require("telescope.builtin")

    -- TODO: Add more keymaps
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[f]ind [f]iles in CWD" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[f]ind [g]rep - Search for a string in CWD" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[f]ind [b]uffers - Lists open buffers in current nvim instance" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[f]ind [h]elp tags" })
    vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "[f]ind [c]ommands - Lists available plugin/user commands" })
  end,
}
