-- Snacks.scroll has issues when scrolling multiple times in a short time so we use neoscroll instead for a smoother experience.
return {
  "karb94/neoscroll.nvim",
  lazy = false,
  opts = {
    -- Keep this empty so Neoscroll does not register its built-in page mappings;
    -- patch.neoscroll.cursor-first installs cursor-first replacements below.
    mappings = {},
    hide_cursor = false,
    duration_multiplier = 0.25,
    cursor_scrolls_alone = true,
  },
  config = function(_, opts)
    require("neoscroll").setup(opts)
    require("patch.neoscroll.cursor-first").setup()
  end,
}
