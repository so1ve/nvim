return {
  languages = {
    ps1 = {
      treesitter = "powershell",
      lsp = { "powershell_es" },
      formatters = { lsp_format = "never" },
    },
  },
  servers = {
    powershell_es = {
      bundle_path = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages", "powershell-editor-services"),
    },
  },
}
