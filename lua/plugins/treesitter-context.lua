return {
  "nvim-treesitter/nvim-treesitter-context",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    enable = true,
    max_lines = 3,
    mode = "cursor",
    multiline_threshold = 3,
    trim_scope = "outer",
  },
  keys = {
    {
      "[c",
      function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end,
      desc = "Go to sticky context",
    },
  },
}
