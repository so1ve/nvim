return {
  languages = {
    python = {
      treesitter = "python",
      lsp = { "basedpyright", "ruff" },
      formatters = { "ruff_organize_imports", "ruff_format" },
    },
  },
  servers = {
    basedpyright = {
      settings = {
        basedpyright = {
          analysis = {
            diagnosticSeverityOverrides = {
              reportUnusedImport = "none",
              reportUnusedVariable = "none",
            },
            typeCheckingMode = "standard",
          },
        },
      },
    },
    ruff = {
      init_options = {
        settings = {
          fixAll = true,
          lint = {
            extendSelect = { "I" },
          },
          organizeImports = true,
        },
      },
      on_attach = function(client)
        client.server_capabilities.hoverProvider = false
      end,
    },
  },
}
