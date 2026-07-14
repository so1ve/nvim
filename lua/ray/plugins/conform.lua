vim.env.PRETTIERD_LOCAL_PRETTIER_ONLY = "1"

local prettier = { "prettierd", "prettier", stop_after_first = true }

return {
  "stevearc/conform.nvim",
  cmd = { "ConformInfo" },
  event = { "BufWritePre" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true })
      end,
      mode = { "n", "v" },
      desc = "Format buffer",
    },
  },
  opts = {
    default_format_opts = {
      lsp_format = "fallback",
    },
    formatters_by_ft = {
      css = prettier,
      html = prettier,
      javascript = prettier,
      javascriptreact = prettier,
      json = prettier,
      jsonc = prettier,
      lua = { "stylua" },
      ps1 = { lsp_format = "never" },
      python = { "ruff_organize_imports", "ruff_format" },
      scss = prettier,
      toml = prettier,
      typescript = prettier,
      typescriptreact = prettier,
      vue = prettier,
      yaml = prettier,
    },
    format_after_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return nil
      end

      return {
        async = true,
      }
    end,
  },
}
