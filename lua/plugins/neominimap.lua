return {
  "Isrothy/neominimap.nvim",
  version = "v3.x.x",
  cmd = "Neominimap",
  event = "VeryLazy",
  keys = {
    { "<leader>nm", "<cmd>Neominimap Toggle<cr>", desc = "Toggle minimap" },
    { "<leader>nr", "<cmd>Neominimap Refresh<cr>", desc = "Refresh minimap" },
    { "<leader>nf", "<cmd>Neominimap ToggleFocus<cr>", desc = "Toggle minimap focus" },
    { "<leader>nb", "<cmd>Neominimap BufToggle<cr>", desc = "Toggle buffer minimap" },
    { "<leader>nw", "<cmd>Neominimap WinToggle<cr>", desc = "Toggle window minimap" },
  },
  init = function()
    vim.opt.wrap = false
    vim.opt.sidescrolloff = 36
    vim.g.neominimap = {
      auto_enable = true,
      layout = "float",
      exclude_filetypes = {
        "help",
        "bigfile",
        "snacks_dashboard",
        "snacks_picker_list",
        "neo-tree",
        "trouble",
        "qf",
      },
    }
  end,
}
