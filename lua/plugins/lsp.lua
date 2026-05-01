return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "saghen/blink.cmp",
  },
  config = function()
    vim.diagnostic.config({
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      virtual_text = {
        prefix = "●",
        spacing = 2,
      },
      float = {
        border = "rounded",
        source = true,
      },
    })

    local capabilities = require("blink.cmp").get_lsp_capabilities(vim.lsp.protocol.make_client_capabilities())

    vim.lsp.config("rust_analyzer", {
      capabilities = capabilities,
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
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("RayLsp", { clear = true }),
      desc = "Configure LSP buffer keymaps",
      callback = function(event)
        local bufnr = event.buf
        local function map(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("K", vim.lsp.buf.hover, "Hover documentation")
        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("gI", vim.lsp.buf.implementation, "Go to implementation")
        map("gr", vim.lsp.buf.references, "References")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
      end,
    })

  end,
}
