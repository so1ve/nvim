return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "saghen/blink.cmp",
  },
  config = function()
    local languages = require("config.languages")

    vim.diagnostic.config({
      update_in_insert = true,
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

    for server_name, server_config in pairs(languages.lsp_configs(capabilities)) do
      vim.lsp.config(server_name, server_config)
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("RayLsp", { clear = true }),
      desc = "Configure LSP buffer keymaps",
      callback = function(event)
        local bufnr = event.buf
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        local inlay_hint_method = vim.lsp.protocol.Methods.textDocument_inlayHint
        local supports_inlay_hints = client and client:supports_method(inlay_hint_method, bufnr)

        local function map(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("K", vim.lsp.buf.hover, "Hover documentation")
        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("gI", vim.lsp.buf.implementation, "Go to implementation")
        map("gr", vim.lsp.buf.references, "References")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        if supports_inlay_hints then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

          map("<leader>ci", function()
            local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
            vim.lsp.inlay_hint.enable(not is_enabled, { bufnr = bufnr })
          end, "Toggle inlay hints")
        end
        map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
      end,
    })

  end,
}
