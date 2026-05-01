return {
  {
    "mason-org/mason.nvim",
    lazy = false,
    cmd = { "Mason", "MasonInstall", "MasonLog", "MasonUninstall", "MasonUpdate" },
    opts = {
      PATH = "prepend",
      ui = {
        border = "rounded",
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    lazy = false,
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = function()
      return {
        ensure_installed = require("config.languages").lsp_server_names(),
        automatic_enable = false,
      }
    end,
  },
}
