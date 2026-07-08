return {
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
