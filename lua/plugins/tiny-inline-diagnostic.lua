return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "LspAttach",
  keys = {
    { "<leader>di", "<cmd>TinyInlineDiag toggle<cr>", desc = "Toggle inline diagnostics" },
    { "<leader>dI", "<cmd>TinyInlineDiag toggle_cursor_only<cr>", desc = "Toggle cursor-only diagnostics" },
  },
  opts = {
    hi = {
      background = "Normal",
    },
    options = {
      show_source = { enabled = true, if_many = true },
      throttle = 0,
      multilines = { enabled = true },
      override_open_float = true,
    },
  },
  config = function(_, opts)
    vim.diagnostic.config({ update_in_insert = false })
    require("tiny-inline-diagnostic").setup(opts)
  end,
}
