return {
  languages = {
    html = {
      treesitter = "html",
      lsp = { "html", "stylelint_lsp" },
    },
    css = {
      treesitter = "css",
      lsp = { "cssls", "stylelint_lsp" },
    },
    scss = {
      treesitter = "scss",
      lsp = { "cssls", "stylelint_lsp" },
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
