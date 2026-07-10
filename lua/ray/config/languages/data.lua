local formatters = require("ray.config.formatters")

return {
  filetypes = {
    extension = {
      json5 = "jsonc",
    },
  },
  languages = {
    json = {
      treesitter = "json",
      lsp = { "jsonls", "eslint" },
      tools = formatters.prettier_tools,
      formatters = formatters.prettier_formatters,
    },
    jsonc = {
      treesitter = "json",
      lsp = { "jsonls", "eslint" },
      tools = formatters.prettier_tools,
      formatters = formatters.prettier_formatters,
    },
    toml = {
      treesitter = "toml",
      lsp = { "tombi" },
      tools = formatters.prettier_tools,
      formatters = formatters.prettier_formatters,
    },
    yaml = {
      treesitter = "yaml",
      lsp = { "yamlls" },
      tools = formatters.prettier_tools,
      formatters = formatters.prettier_formatters,
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
            schemas = require("schemastore").json.schemas(),
            validate = {
              enable = true,
            },
          },
        },
      }
    end,
    tombi = {
      settings = {
        tombi = {
          extensions = {
            ["tombi-toml/cargo"] = {
              lsp = {
                ["code-action"] = {
                  ["update-dependency-to-latest-version"] = {
                    enabled = false,
                  },
                },
              },
            },
          },
        },
      },
    },
    yamlls = {
      filetypes = { "yaml" },
      capabilities = {
        textDocument = {
          foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
          },
        },
      },
      before_init = function(_, config)
        config.settings.yaml.schemas =
          vim.tbl_deep_extend("force", config.settings.yaml.schemas or {}, require("schemastore").yaml.schemas())
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
