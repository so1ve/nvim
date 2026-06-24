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
