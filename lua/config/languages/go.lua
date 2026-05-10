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
