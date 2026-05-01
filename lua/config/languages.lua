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
  vue_ls = {},
  jsonls = {},
  taplo = {},
  yamlls = {},
  html = {},
  cssls = {},
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
    lsp = { "vtsls" },
  },
  javascript = {
    treesitter = "javascript",
    lsp = { "vtsls" },
  },
  typescriptreact = {
    treesitter = "tsx",
    lsp = { "vtsls" },
  },
  javascriptreact = {
    treesitter = "javascript",
    lsp = { "vtsls" },
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
    lsp = { "html" },
  },
  css = {
    treesitter = "css",
    lsp = { "cssls" },
  },
  scss = {
    treesitter = "scss",
    lsp = { "cssls" },
  },
  vue = {
    treesitter = "vue",
    lsp = { "vtsls", "vue_ls" },
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

  for server_name, server in pairs(M.lsp_servers) do
    configs[server_name] = vim.tbl_deep_extend("force", { capabilities = capabilities }, server)
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
