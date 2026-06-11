return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "lewis6991/async.nvim",
  },
  opts = {},
  keys = {
    {
      "<leader>rf",
      function()
        require("refactoring").extract_func()
      end,
      mode = "x",
      desc = "Extract function",
    },
    {
      "<leader>rF",
      function()
        require("refactoring").extract_func_to_file()
      end,
      mode = "x",
      desc = "Extract function to file",
    },
    {
      "<leader>rv",
      function()
        require("refactoring").extract_var()
      end,
      mode = "x",
      desc = "Extract variable",
    },
    {
      "<leader>ri",
      function()
        require("refactoring").inline_var()
      end,
      mode = { "n", "x" },
      desc = "Inline variable",
    },
    {
      "<leader>rI",
      function()
        require("refactoring").inline_func()
      end,
      mode = { "n", "x" },
      desc = "Inline function",
    },
    {
      "<leader>rs",
      function()
        require("refactoring").select_refactor()
      end,
      mode = { "n", "x" },
      desc = "Select refactor",
    },
  },
}
