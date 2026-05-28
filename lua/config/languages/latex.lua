return {
  languages = {
    bib = {
      lsp = { "texlab" },
    },
    plaintex = {
      treesitter = "latex",
      lsp = { "texlab" },
      tools = { "latexindent" },
    },
    tex = {
      treesitter = "latex",
      lsp = { "texlab" },
      tools = { "latexindent" },
    },
  },
  servers = {
    texlab = {
      settings = {
        texlab = {
          latexFormatter = "latexindent",
          latexindent = {
            modifyLineBreaks = false,
          },
        },
      },
    },
  },
}
