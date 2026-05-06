return {
  languages = {
    rust = {
      treesitter = "rust",
      lsp = { "rust_analyzer" },
      formatters = { "rustfmt" },
    },
  },
  servers = {
    rust_analyzer = {
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            features = "all",
          },
          check = {
            command = "clippy",
          },
          rustfmt = {
            rangeFormatting = {
              enable = true,
            },
          },
        },
      },
    },
  },
}
