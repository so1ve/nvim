local schemastore = require("config.schemastore")

return {
  languages = {
    json = {
      treesitter = "json",
      lsp = { "jsonls" },
    },
    jsonc = {
      treesitter = "json",
      lsp = { "jsonls" },
    },
    toml = {
      treesitter = "toml",
      lsp = { "taplo" },
    },
    yaml = {
      treesitter = "yaml",
      lsp = { "yamlls" },
    },
  },
  servers = {
    jsonls = function()
      return {
        settings = {
          json = {
            format = {
              enable = true,
            },
            schemas = schemastore.json_schemas(),
            validate = {
              enable = true,
            },
          },
        },
      }
    end,
    taplo = {
      before_init = schemastore.set_taplo_catalog,
      settings = {
        evenBetterToml = {
          schema = {
            enabled = true,
          },
        },
      },
    },
    yamlls = {
      capabilities = {
        textDocument = {
          foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
          },
        },
      },
      before_init = function(_, config)
        config.settings = config.settings or {}
        config.settings.yaml = config.settings.yaml or {}
        config.settings.yaml.schemas =
          vim.tbl_deep_extend("force", config.settings.yaml.schemas or {}, schemastore.yaml_schemas())
      end,
      settings = {
        redhat = {
          telemetry = {
            enabled = false,
          },
        },
        yaml = {
          keyOrdering = false,
          format = {
            enable = true,
          },
          validate = true,
          schemaStore = {
            enable = false,
            url = "",
          },
        },
      },
    },
  },
}
