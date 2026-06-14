vim.g.filetype_typ = "typst"

return {
  languages = {
    typst = {
      treesitter = "typst",
      lsp = { "tinymist" },
    },
  },
  servers = {
    tinymist = {
      settings = {
        formatterMode = "typstyle",
      },
    },
  },
}
