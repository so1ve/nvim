local function with_project_settings(config)
  local before_init = config.before_init

  return vim.tbl_extend("force", config, {
    before_init = function(init_params, client_config)
      if before_init then
        before_init(init_params, client_config)
      end

      local loader = require("codesettings").loader()
      if client_config.root_dir then
        loader = loader:root_dir(client_config.root_dir)
      end

      local client_rename = {
        ["rust_analyzer"] = "rust-analyzer",
      }
      local settings_name = client_rename[client_config.name] or client_config.name
      loader:with_local_settings(settings_name, client_config)
    end,
  })
end

local function expand_rust_macro(client, bufnr)
  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)

  client:request("rust-analyzer/expandMacro", params, function(err, result)
    if err then
      vim.notify(err.message or "Failed to expand macro", vim.log.levels.ERROR)
      return
    end

    if not result then
      vim.notify("No macro under cursor", vim.log.levels.INFO)
      return
    end

    vim.schedule(function()
      local expansion_bufnr = vim.api.nvim_create_buf(false, true)

      vim.api.nvim_buf_set_lines(expansion_bufnr, 0, -1, false, vim.split(result.expansion, "\r?\n"))
      vim.bo[expansion_bufnr].bufhidden = "wipe"
      vim.bo[expansion_bufnr].filetype = "rust"
      vim.bo[expansion_bufnr].modifiable = false

      vim.cmd("botright vsplit")
      vim.api.nvim_win_set_buf(0, expansion_bufnr)
    end)
  end, bufnr)
end

local function configure_lsp_buffer(event)
  local bufnr = event.buf
  local client = vim.lsp.get_client_by_id(event.data.client_id)

  if not client then
    return
  end

  local inlay_hint_method = vim.lsp.protocol.Methods.textDocument_inlayHint
  local symbol_method = vim.lsp.protocol.Methods.textDocument_documentSymbol
  local workspace_symbol_method = vim.lsp.protocol.Methods.workspace_symbol
  local supports_inlay_hints = client:supports_method(inlay_hint_method, bufnr)
  local supports_document_symbols = client:supports_method(symbol_method, bufnr)
  local supports_workspace_symbols = client:supports_method(workspace_symbol_method)

  local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
  end

  map("K", function()
    require("tiny-md.hover").hover()
  end, "Hover documentation")
  map("gd", Snacks.picker.lsp_definitions, "Go to definition")
  map("gD", Snacks.picker.lsp_declarations, "Go to declaration")
  map("gI", Snacks.picker.lsp_implementations, "Go to implementation")
  map("gr", Snacks.picker.lsp_references, "References")
  map("gy", Snacks.picker.lsp_type_definitions, "Go to type definition")
  vim.keymap.set({ "n", "x" }, "<leader>ca", function()
    require("code-action-menu").code_action()
  end, { buffer = bufnr, desc = "Code action" })

  if supports_document_symbols then
    map("<leader>fs", Snacks.picker.lsp_symbols, "Document symbols")
  end

  if supports_workspace_symbols then
    map("<leader>fS", Snacks.picker.lsp_workspace_symbols, "Workspace symbols")
  end

  if supports_inlay_hints then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    map("<leader>ci", function()
      local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })

      vim.lsp.inlay_hint.enable(not is_enabled, { bufnr = bufnr })
    end, "Toggle inlay hints")
  end

  map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
end

local tsserver_language_settings = {
  updateImportsOnFileMove = { enabled = "always" },
  suggest = {
    completeFunctionCalls = true,
  },
}

local servers = {
  ["*"] = {
    capabilities = {
      workspace = {
        fileOperations = {
          didRename = true,
          willRename = true,
        },
      },
    },
  },
  cssls = {},
  docker_compose_language_service = {},
  dockerls = {},
  gopls = {},
  html = {},
  marksman = {},
  unocss = {},
  vue_ls = {},
  zls = {},
  clangd = {
    cmd = {
      "clangd",
      "--background-index",
      "--completion-style=detailed",
      "--header-insertion=iwyu",
    },
  },
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
    filetypes = { "yaml", "yaml.github-actions" },
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
  eslint = {
    before_init = function(_, config)
      if not config.root_dir then
        return
      end

      -- vscode-eslint expects a file URI here. On Windows, the upstream
      -- default raw path can make projectService resolve test files wrong.
      config.settings.workspaceFolder = {
        name = vim.fn.fnamemodify(config.root_dir, ":t"),
        uri = vim.uri_from_fname(config.root_dir),
      }
    end,
    filetypes = {
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "vue",
      "html",
      "markdown",
      "mdc",
      "json",
      "jsonc",
      "toml",
      "yaml",
      "yaml.github-actions",
      "svelte",
      "astro",
    },
    settings = {
      format = false,
      workingDirectory = {
        mode = "location",
      },
    },
  },
  texlab = {
    settings = {
      texlab = {
        latexFormatter = "latexindent",
        latexindent = {
          modifyLineBreaks = false,
        },
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = "Replace",
        },
        codeLens = {
          enable = true,
        },
        diagnostics = {
          globals = { "vim" },
        },
        runtime = {
          path = { "lua/?.lua", "lua/?/init.lua" },
          version = "LuaJIT",
        },
        telemetry = {
          enable = false,
        },
        workspace = {
          checkThirdParty = false,
        },
        doc = {
          privateName = { "^_" },
        },
        hint = {
          enable = true,
          setType = false,
          paramType = true,
          paramName = "Disable",
          semicolon = "Disable",
          arrayIndex = "Disable",
        },
      },
    },
  },
  powershell_es = {
    bundle_path = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "packages", "powershell-editor-services"),
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
  vtsls = {
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
      "vue",
    },
    settings = {
      complete_function_calls = true,
      vtsls = {
        autoUseWorkspaceTsdk = true,
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
              enableForWorkspaceTypeScriptVersions = true,
            },
          },
        },
        experimental = {
          maxInlayHintLength = 30,
          completion = {
            enableServerSideFuzzyMatch = true,
          },
        },
      },
      typescript = tsserver_language_settings,
      javascript = tsserver_language_settings,
    },
  },
  tinymist = {
    settings = {
      formatterMode = "typstyle",
    },
  },
  rust_analyzer = {
    on_attach = function(client, bufnr)
      vim.keymap.set("n", "<leader>ce", function()
        expand_rust_macro(client, bufnr)
      end, { buffer = bufnr, desc = "Expand macro" })
    end,
    settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true,
          loadOutDirsFromCheck = true,
          buildScripts = {
            enable = true,
          },
        },
        checkOnSave = true,
        check = {
          command = "clippy",
        },
        diagnostics = {
          enable = true,
        },
        files = {
          exclude = {
            ".direnv",
            ".git",
            ".github",
            ".gitlab",
            ".jj",
            ".venv",
            "bin",
            "node_modules",
            "target",
            "venv",
          },
          watcher = "client",
        },
        procMacro = {
          enable = true,
        },
        rustfmt = {
          rangeFormatting = {
            enable = true,
          },
        },
      },
    },
  },
  stylelint_lsp = {
    filetypes = { "css", "scss", "html", "vue" },
    settings = {
      stylelint = {
        validate = { "css", "scss", "html", "vue" },
      },
    },
  },
}

return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "wezterm-types", mods = { "wezterm" } },
      },
    },
  },
  { "DrKJeff16/wezterm-types" },
  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = {
        crates = {
          enabled = true,
        },
      },
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
  },

  {
    "so1ve/code-action-menu.nvim",
    event = "LspAttach",
    opts = {},
  },
  {
    "so1ve/noicelet.nvim",
    event = "LspAttach",
    opts = {
      window = {
        x_padding = 10,
        y_padding = 2,
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "saghen/blink.cmp",
      "b0o/schemastore.nvim",
    },
    config = function()
      for server_name, config in pairs(servers) do
        vim.lsp.config(server_name, with_project_settings(type(config) == "function" and config() or config))

        if server_name ~= "*" then
          vim.lsp.enable(server_name)
        end
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = configure_lsp_buffer,
      })
    end,
  },
}
