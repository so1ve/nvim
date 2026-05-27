return {
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
}
