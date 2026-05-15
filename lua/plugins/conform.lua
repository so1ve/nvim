require("config.formatters")

return {
  "stevearc/conform.nvim",
  cmd = { "ConformInfo" },
  event = { "BufWritePre" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback", timeout_ms = 10000 })
      end,
      mode = { "n", "v" },
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = require("config.languages").map("formatters"),
    format_after_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return nil
      end

      return {
        lsp_format = "fallback",
        timeout_ms = 10000,
      }
    end,
  },
}
