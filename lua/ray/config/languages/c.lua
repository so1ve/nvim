return {
  languages = {
    c = {
      treesitter = "c",
      lsp = { "clangd" },
    },
    cpp = {
      treesitter = "cpp",
      lsp = { "clangd" },
    },
  },
  servers = {
    clangd = {
      cmd = {
        "clangd",
        "--background-index",
        "--completion-style=detailed",
        "--header-insertion=iwyu",
      },
    },
  },
}
