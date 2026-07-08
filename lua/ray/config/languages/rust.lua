return {
  languages = {
    rust = {
      treesitter = "rust",
      -- use lsp fallback instead
      -- because lsp has some options to configure rustfmt
      -- formatters = { "rustfmt" }
    },
  },
  plugins = {
    {
      "mrcjkb/rustaceanvim",
      version = vim.version.range("^9"),
      lazy = false,
      init = function()
        vim.g.rustaceanvim = {
          server = {
            on_attach = function(_, bufnr)
              vim.keymap.set("n", "<leader>ce", function()
                vim.cmd.RustLsp("expandMacro")
              end, { buffer = bufnr, desc = "Expand macro" })
            end,
            settings = function(project_root, default_settings)
              return require("codesettings").loader():root_dir(project_root):with_local_settings("rust-analyzer", {
                settings = default_settings,
              }).settings
            end,
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
            autoload_configurations = false,
            adapter = false,
          },
        }
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
