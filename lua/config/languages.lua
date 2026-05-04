local M = {}

M.lsp_servers = {
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
  vtsls = {
    filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
    settings = {
      vtsls = {
        tsserver = {
          globalPlugins = {
            {
              name = "@vue/typescript-plugin",
              location = vim.fs.joinpath(
                vim.fn.stdpath("data"),
                "mason",
                "packages",
                "vue-language-server",
                "node_modules",
                "@vue",
                "language-server"
              ),
              languages = { "vue" },
              configNamespace = "typescript",
            },
          },
        },
      },
    },
  },
  eslint = {
    before_init = function(_, config)
      if not config.root_dir then
        return
      end

      config.settings = config.settings or {}
      config.settings.workspaceFolder = {
        name = vim.fn.fnamemodify(config.root_dir, ":t"),
        uri = vim.uri_from_fname(config.root_dir),
      }
    end,
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
    settings = {
      format = false,
    },
  },
  vue_ls = {},
  jsonls = {},
  taplo = {
    before_init = function(_, config)
      config.settings = config.settings or {}
      config.settings.evenBetterToml = config.settings.evenBetterToml or {}
      config.settings.evenBetterToml.schema = config.settings.evenBetterToml.schema or {}
      config.settings.evenBetterToml.schema.catalogs = {
        require("config.taplo_schema_catalog").uri(),
      }
    end,
    settings = {
      evenBetterToml = {
        schema = {
          enabled = true,
        },
      },
    },
  },
  yamlls = {},
  html = {},
  cssls = {},
  stylelint_lsp = {
    filetypes = { "css", "scss", "vue", "html" },
    settings = {
      stylelint = {
        validate = { "css", "scss", "vue", "html" },
      },
    },
  },
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
  gopls = {
    settings = {
      gopls = {
        gofumpt = true,
      },
    },
  },
}

M.languages = {
  rust = {
    treesitter = "rust",
    lsp = { "rust_analyzer" },
    formatters = { "rustfmt" },
  },
  typescript = {
    treesitter = "typescript",
    lsp = { "vtsls", "eslint" },
  },
  javascript = {
    treesitter = "javascript",
    lsp = { "vtsls", "eslint" },
  },
  typescriptreact = {
    treesitter = "tsx",
    lsp = { "vtsls", "eslint" },
  },
  javascriptreact = {
    treesitter = "javascript",
    lsp = { "vtsls", "eslint" },
  },
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
  html = {
    treesitter = "html",
    lsp = { "html", "stylelint_lsp" },
  },
  css = {
    treesitter = "css",
    lsp = { "cssls", "stylelint_lsp" },
  },
  scss = {
    treesitter = "scss",
    lsp = { "cssls", "stylelint_lsp" },
  },
  python = {
    treesitter = "python",
    lsp = { "basedpyright", "ruff" },
    formatters = { "ruff_organize_imports", "ruff_format" },
  },
  vue = {
    treesitter = "vue",
    lsp = { "vtsls", "vue_ls", "eslint", "stylelint_lsp" },
  },
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
}

-- noice.nvim
M.extra_treesitter_parsers = {
  "bash",
  "lua",
  "markdown",
  "markdown_inline",
  "regex",
  "vim",
}

function M.treesitter_language(filetype)
  if filetype == "" then
    return nil
  end

  local language = M.languages[filetype]
  if language and language.treesitter then
    return language.treesitter
  end

  return vim.treesitter.language.get_lang(filetype)
end

function M.treesitter_aliases()
  local aliases = {}

  for filetype, language in pairs(M.languages) do
    local parser = language.treesitter
    if parser and parser ~= filetype then
      aliases[parser] = aliases[parser] or {}
      table.insert(aliases[parser], filetype)
    end
  end

  return aliases
end

function M.lsp_configs(capabilities)
  local configs = {}

  for server_name, server_config in pairs(M.lsp_servers) do
    configs[server_name] = vim.tbl_deep_extend("force", { capabilities = capabilities }, server_config)
  end

  return configs
end

function M.lsp_server_names()
  local names = {}
  local seen = {}

  for _, language in pairs(M.languages) do
    for _, server_name in ipairs(language.lsp or {}) do
      if not M.lsp_servers[server_name] then
        error("Missing LSP server config: " .. server_name)
      end

      if not seen[server_name] then
        seen[server_name] = true
        table.insert(names, server_name)
      end
    end
  end

  return names
end

function M.treesitter_parsers()
  local parsers = {}
  local seen = {}

  for filetype, language in pairs(M.languages) do
    local parser = language.treesitter or vim.treesitter.language.get_lang(filetype)
    if parser and not seen[parser] then
      seen[parser] = true
      table.insert(parsers, parser)
    end
  end

  for _, parser in ipairs(M.extra_treesitter_parsers) do
    if not seen[parser] then
      seen[parser] = true
      table.insert(parsers, parser)
    end
  end

  return parsers
end

function M.formatters_by_ft()
  local formatters = {}

  for filetype, language in pairs(M.languages) do
    if language.formatters then
      formatters[filetype] = language.formatters
    end
  end

  return formatters
end

return M
