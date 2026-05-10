return {
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonLog", "MasonUninstall", "MasonUpdate" },
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts_extend = { "ensure_installed", "automatic_enable" },
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = function()
      local servers = require("config.languages").collect("lsp")

      return {
        ensure_installed = servers,
        automatic_enable = servers,
      }
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    opts_extend = { "ensure_installed" },
    dependencies = {
      "mason-org/mason.nvim",
    },
    opts = function()
      return {
        ensure_installed = require("config.languages").collect("tools"),
        run_on_start = true,
        start_delay = 3000,
        debounce_hours = 12,
      }
    end,
  },
}
