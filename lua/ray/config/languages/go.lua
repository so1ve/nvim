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
      build = function()
        vim.system({ "go", "install", "gotest.tools/gotestsum@latest" }):wait() -- Optional, but recommended
      end,
      opts = {
        adapters = {
          ["neotest-golang"] = {
            runner = "gotestsum",
          },
        },
      },
    },
  },
}
