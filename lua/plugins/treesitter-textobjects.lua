return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  opts = {
    move = {
      set_jumps = true,
    },
  },
  keys = {
    {
      "]f",
      function()
        require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer")
      end,
      mode = { "n", "x", "o" },
      desc = "Next function start",
    },
    {
      "[f",
      function()
        require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer")
      end,
      mode = { "n", "x", "o" },
      desc = "Previous function start",
    },
    {
      "]F",
      function()
        require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer")
      end,
      mode = { "n", "x", "o" },
      desc = "Next function end",
    },
    {
      "[F",
      function()
        require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer")
      end,
      mode = { "n", "x", "o" },
      desc = "Previous function end",
    },
    {
      "]a",
      function()
        require("nvim-treesitter-textobjects.move").goto_next_start("@parameter.inner")
      end,
      mode = { "n", "x", "o" },
      desc = "Next parameter",
    },
    {
      "[a",
      function()
        require("nvim-treesitter-textobjects.move").goto_previous_start("@parameter.inner")
      end,
      mode = { "n", "x", "o" },
      desc = "Previous parameter",
    },
    {
      "<leader>a",
      function()
        require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
      end,
      desc = "Swap next parameter",
    },
    {
      "<leader>A",
      function()
        require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
      end,
      desc = "Swap previous parameter",
    },
  },
  config = true,
}
