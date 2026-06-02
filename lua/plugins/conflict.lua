return {
  "niekdomi/conflict.nvim",
  cmd = "Conflict",
  event = { "BufReadPost", "BufNewFile" },
  keys = {
    { "<leader>gcl", "<cmd>Conflict list<cr>", desc = "Git conflict files" },
    { "<leader>gcq", "<cmd>Conflict qflist<cr>", desc = "Git conflicts quickfix" },
    { "<leader>gcr", "<cmd>Conflict refresh<cr>", desc = "Refresh git conflicts" },
  },
  opts = {
    default_mappings = {
      current = "<leader>gcc",
      incoming = "<leader>gci",
      both = "<leader>gcb",
      base = "<leader>gcB",
      none = false,
      next = "<leader>gcn",
      prev = "<leader>gcp",
    },
  },
}
