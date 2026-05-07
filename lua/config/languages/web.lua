local formatters = require("config.formatters")

return {
  languages = {
    html = {
      treesitter = "html",
      lsp = { "html", "stylelint_lsp" },
      formatters = formatters.prettier(),
    },
    css = {
      treesitter = "css",
      lsp = { "cssls", "stylelint_lsp" },
      formatters = formatters.prettier(),
    },
    scss = {
      treesitter = "scss",
      lsp = { "cssls", "stylelint_lsp" },
      formatters = formatters.prettier(),
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
