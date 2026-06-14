return {
  languages = {
    go = {
      treesitter = "go",
      lsp = { "gopls" },
      tools = { "goimports", "gofumpt" },
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
  plugins = {
    {
      "nvim-neotest/neotest",
      optional = true,
      dependencies = {
        "fredrikaverpil/neotest-golang",
      },
      opts = {
        adapters = {
          ["neotest-golang"] = {
            -- go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
          },
        },
      },
    },
  },
}
