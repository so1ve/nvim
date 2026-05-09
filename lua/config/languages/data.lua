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
            exclude = { "Cargo.toml", "**/Cargo.toml" },
          },
        },
      },
    },
    yamlls = {},
  },
}
