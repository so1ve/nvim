return {
  "dlyongemallo/diffview-plus.nvim",
  main = "diffview",
  cmd = {
    "DiffviewOpen",
    "DiffviewToggle",
    "DiffviewFileHistory",
    "DiffviewDiffFiles",
    "DiffviewMergeFiles",
    "DiffviewDiffDirs",
    "DiffviewClose",
  },
  opts = function()
    local close = "<cmd>DiffviewClose<cr>"
    local close_map = { "n", "q", close, { desc = "Close Diffview" } }

    return {
      keymaps = {
        view = { close_map },
        file_panel = { close_map },
        file_history_panel = { close_map },
      },
    }
  end,
}
