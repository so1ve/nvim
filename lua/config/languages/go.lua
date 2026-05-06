return {
  languages = {
    go = {
      treesitter = "go",
      lsp = { "gopls" },
    },
    gomod = {
      treesitter = "gomod",
      lsp = { "gopls" },
    },
    gowork = {
      treesitter = "gowork",
      lsp = { "gopls" },
    },
    gotmpl = {
      treesitter = "gotmpl",
      lsp = { "gopls" },
    },
    gosum = {
      treesitter = "gosum",
    },
  },
  servers = {
    gopls = {
      settings = {
        gopls = {
          gofumpt = true,
        },
      },
    },
  },
}
