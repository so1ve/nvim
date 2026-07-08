return {
  languages = {
    python = {
      treesitter = "python",
      lsp = { "basedpyright", "ruff" },
      tools = { "ruff" },
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
      cmd_env = {
        RUFF_TRACE = "messages",
      },
      init_options = {
        settings = {
          fixAll = true,
          logLevel = "error",
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
