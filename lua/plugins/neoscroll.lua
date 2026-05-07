-- Snacks.scroll has issues when scrolling multiple times in a short time so we use neoscroll instead for a smoother experience.
return {
  "karb94/neoscroll.nvim",
  lazy = false,
  opts = {
    mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>" },
    hide_cursor = false,
    duration_multiplier = 0.25,
    cursor_scrolls_alone = true,
  },
}
