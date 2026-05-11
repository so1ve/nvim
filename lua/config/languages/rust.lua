local function rust_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  capabilities.workspace = capabilities.workspace or {}
  capabilities.workspace.fileOperations = {
    didRename = true,
    willRename = true,
  }

  capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
  capabilities.experimental = capabilities.experimental or {}
  capabilities.experimental.codeActionGroup = true

  return capabilities
end

local function rust_lsp(command)
  return function()
    vim.cmd.RustLsp(command)
  end
end

local function rust_lsp_command(command)
  local command_args = vim.split(command, " ", { trimempty = true })

  return function(args)
    local rust_args = vim.list_extend(vim.deepcopy(command_args), args.fargs)

    vim.api.nvim_cmd({ cmd = "RustLsp", args = rust_args }, {})
  end
end

local function refresh_rust_diagnostics(args)
  local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "rust_analyzer" })

  if #clients > 0 then
    vim.lsp.diagnostic._refresh(args.buf)
  end
end

local function setup_rust_autocmds()
  vim.api.nvim_create_autocmd("FileChangedShellPost", {
    desc = "Refresh Rust diagnostics after external file reload",
    pattern = "*.rs",
    callback = refresh_rust_diagnostics,
  })
end

local function attach_rust_keymaps(_, bufnr)
  local commands = {
    RustCrateGraph = { "crateGraph", "View crate graph" },
    RustExplainError = { "explainError", "Explain Rust diagnostic" },
    RustExpandMacro = { "expandMacro", "Expand macro at caret" },
    RustOpenCargo = { "openCargo", "Open Cargo.toml" },
    RustOpenDocs = { "openDocs", "Open docs.rs for symbol" },
    RustRelatedDiagnostics = { "relatedDiagnostics", "Show related Rust diagnostics" },
    RustRelatedTests = { "relatedTests", "Show related Rust tests" },
    RustRenderDiagnostic = { "renderDiagnostic", "Render Rust diagnostic" },
    RustSsr = { "ssr", "Run structural search replace" },
    RustSyntaxTree = { "syntaxTree", "View rust-analyzer syntax tree" },
    RustViewHir = { "view hir", "View HIR for item at cursor" },
    RustViewMir = { "view mir", "View MIR for item at cursor" },
  }

  for name, command in pairs(commands) do
    vim.api.nvim_buf_create_user_command(bufnr, name, rust_lsp_command(command[1]), {
      desc = command[2],
      nargs = "*",
    })
  end

  vim.keymap.set("n", "<leader>ce", rust_lsp("expandMacro"), { buffer = bufnr, desc = "Expand macro" })
  vim.keymap.set("n", "<leader>dr", rust_lsp("debuggables"), { buffer = bufnr, desc = "Rust debuggables" })
end

local function codelldb_adapter()
  local codelldb = vim.fn.exepath("codelldb")

  if codelldb == "" then
    return nil
  end

  local lib_ext = vim.fn.has("win32") == 1 and ".dll" or vim.uv.os_uname().sysname == "Linux" and ".so" or ".dylib"
  local liblldb = vim.fn.expand("$MASON/opt/lldb/lib/liblldb" .. lib_ext)

  if vim.uv.fs_stat(liblldb) then
    return require("rustaceanvim.config").get_codelldb_adapter(codelldb, liblldb)
  end

  return nil
end

return {
  languages = {
    rust = {
      treesitter = "rust",
      tools = { "codelldb" },
      formatters = { "rustfmt" },
    },
  },
  plugins = {
    {
      "mrcjkb/rustaceanvim",
      version = "^9",
      lazy = false,
      opts = {
        tools = {
          reload_workspace_from_cargo_toml = true,
          test_executor = "background",
          float_win_config = {
            auto_focus = true,
            open_split = "vertical",
          },
        },
        server = {
          on_attach = attach_rust_keymaps,
          default_settings = {
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
        dap = {
          autoload_configurations = true,
        },
      },
      config = function(_, opts)
        local user_config = type(vim.g.rustaceanvim) == "table" and vim.g.rustaceanvim or {}

        setup_rust_autocmds()

        vim.g.rustaceanvim = function()
          local config = vim.deepcopy(opts)
          local adapter = codelldb_adapter()

          config.server.capabilities = rust_capabilities()

          if adapter then
            config.dap.adapter = adapter
          end

          return vim.tbl_deep_extend("keep", user_config, config)
        end
      end,
    },
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
      "nvim-neotest/neotest",
      optional = true,
      opts = {
        adapters = {
          ["rustaceanvim.neotest"] = {},
        },
      },
    },
  },
}
