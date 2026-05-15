local formatters = require("config.formatters")

return {
  languages = {
    html = {
      treesitter = "html",
      lsp = { "html", "stylelint_lsp" },
      tools = formatters.prettier_tools,
      formatters = formatters.prettier_formatters,
    },
    css = {
      treesitter = "css",
      lsp = { "cssls", "stylelint_lsp" },
      tools = formatters.prettier_tools,
      formatters = formatters.prettier_formatters,
    },
    scss = {
      treesitter = "scss",
      lsp = { "cssls", "stylelint_lsp" },
      tools = formatters.prettier_tools,
      formatters = formatters.prettier_formatters,
    },
  },
  servers = {
    html = {},
    cssls = {},
    stylelint_lsp = {
      filetypes = { "css", "scss", "html" },
      settings = {
        stylelint = {
          validate = { "css", "scss", "html", "vue" },
        },
      },
    },
  },
}
