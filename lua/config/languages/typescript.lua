local formatters = require("config.formatters")

return {
  languages = {
    typescript = {
      treesitter = "typescript",
      lsp = { "vtsls", "eslint" },
      formatters = formatters.prettier(),
    },
    javascript = {
      treesitter = "javascript",
      lsp = { "vtsls", "eslint" },
      formatters = formatters.prettier(),
    },
    typescriptreact = {
      treesitter = "tsx",
      lsp = { "vtsls", "eslint" },
      formatters = formatters.prettier(),
    },
    javascriptreact = {
      treesitter = "javascript",
      lsp = { "vtsls", "eslint" },
      formatters = formatters.prettier(),
    },
  },
  servers = {
    vtsls = {
      filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
      settings = {
        vtsls = {
          tsserver = {},
        },
      },
    },
    eslint = {
      before_init = function(_, config)
        if not config.root_dir then
          return
        end

        config.settings = config.settings or {}
        config.settings.workspaceFolder = {
          name = vim.fn.fnamemodify(config.root_dir, ":t"),
          uri = vim.uri_from_fname(config.root_dir),
        }
      end,
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      settings = {
        format = false,
      },
    },
  },
}
