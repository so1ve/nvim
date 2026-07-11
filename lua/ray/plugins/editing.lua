return {
  {
    "gbprod/yanky.nvim",
    dependencies = { "folke/snacks.nvim" },
    keys = {
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put after cursor" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put before cursor" },
      { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put after cursor and move cursor" },
      { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put before cursor and move cursor" },
      { "<C-p>", "<Plug>(YankyPreviousEntry)", desc = "Previous yank" },
      { "<C-n>", "<Plug>(YankyNextEntry)", desc = "Next yank" },
      {
        "<leader>fy",
        function()
          Snacks.picker.yanky()
        end,
        mode = { "n", "x" },
        desc = "Yank history",
      },
    },
    opts = {
      highlight = {
        on_put = false,
        timer = 300,
      },
    },
  },
  -- not using mini.splitjoin because it doesn't support rust match arms
  --
  -- ```
  -- match arm {
  --     true => {
  --         1
  --     }
  -- }
  -- ```
  --
  -- to
  --
  -- ```
  -- match arm {
  --     true => 1
  -- }
  {
    "Wansmer/treesj",
    keys = {
      {
        "gs",
        function()
          require("treesj").toggle()
        end,
        desc = "Toggle split/join",
      },
    },
    opts = {
      use_default_keymaps = false,
    },
  },
  {
    "so1ve/tiny-comment.nvim",
    keys = {
      { "gco", desc = "Add comment below" },
      { "gcO", desc = "Add comment above" },
      { "gcA", desc = "Add comment at end of line" },
    },
    opts = {},
  },
}
