-- Currently need to load via command `:Lazy load ChatGPT.nvim`

return {
  "jackMort/ChatGPT.nvim",
  lazy = true,
  config = function()
    require("chatgpt").setup({
      api_key_cmd = "op read op://Personal/OpenAi/credential --no-newline",
      openai_params = {
        model = "gpt-4o",
        frequency_penalty = 0,
        presence_penalty = 0,
        max_tokens = 300,
        temperature = 0,
        top_p = 1,
        n = 1,
      },
      openai_edit_params = {
        model = "gpt-4o",
        frequency_penalty = 0,
        presence_penalty = 0,
        temperature = 0,
        top_p = 1,
        n = 1,
      },
    })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "nvim-telescope/telescope.nvim",
  },
}
