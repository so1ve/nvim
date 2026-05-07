return {
  languages = {
    html = {
      treesitter = "html",
      lsp = { "html", "stylelint_lsp" },
      tools = { "prettierd" },
      formatters = { "prettierd" },
    },
    css = {
      treesitter = "css",
      lsp = { "cssls", "stylelint_lsp" },
      tools = { "prettierd" },
      formatters = { "prettierd" },
    },
    scss = {
      treesitter = "scss",
      lsp = { "cssls", "stylelint_lsp" },
      tools = { "prettierd" },
      formatters = { "prettierd" },
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
