local function configure_lsp_buffer(event)
  local bufnr = event.buf
  local client = vim.lsp.get_client_by_id(event.data.client_id)
  local inlay_hint_method = vim.lsp.protocol.Methods.textDocument_inlayHint
  local symbol_method = vim.lsp.protocol.Methods.textDocument_documentSymbol
  local supports_inlay_hints = client and client:supports_method(inlay_hint_method, bufnr)
  local supports_document_symbols = client and client:supports_method(symbol_method, bufnr)

  local navic = require("nvim-navic")
  if supports_document_symbols and not navic.is_available(bufnr) then
    navic.attach(client, bufnr)
  end

  local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
  end

  map("K", vim.lsp.buf.hover, "Hover documentation")
  map("gd", Snacks.picker.lsp_definitions, "Go to definition")
  map("gD", Snacks.picker.lsp_declarations, "Go to declaration")
  map("gI", Snacks.picker.lsp_implementations, "Go to implementation")
  map("gr", Snacks.picker.lsp_references, "References")
  map("gy", Snacks.picker.lsp_type_definitions, "Go to type definition")
  map("<leader>ca", vim.lsp.buf.code_action, "Code action")

  if supports_inlay_hints then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    map("<leader>ci", function()
      local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })

      vim.lsp.inlay_hint.enable(not is_enabled, { bufnr = bufnr })
    end, "Toggle inlay hints")
  end

  map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
end

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "saghen/blink.cmp",
    "SmiteshP/nvim-navic",
  },
  config = function()
    local languages = require("config.languages")

    vim.diagnostic.config({
      update_in_insert = false,
      severity_sort = true,
      virtual_text = false,
      virtual_lines = false,
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
      callback = configure_lsp_buffer,
    })
  end,
}
