local function set_lsp_keymap(bufnr, lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
end

local function toggle_lsp_inlay_hints(bufnr)
  local is_enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })

  vim.lsp.inlay_hint.enable(not is_enabled, { bufnr = bufnr })
end

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

  set_lsp_keymap(bufnr, "K", vim.lsp.buf.hover, "Hover documentation")
  set_lsp_keymap(bufnr, "gd", vim.lsp.buf.definition, "Go to definition")
  set_lsp_keymap(bufnr, "gD", vim.lsp.buf.declaration, "Go to declaration")
  set_lsp_keymap(bufnr, "gI", vim.lsp.buf.implementation, "Go to implementation")
  set_lsp_keymap(bufnr, "gr", vim.lsp.buf.references, "References")
  set_lsp_keymap(bufnr, "<leader>ca", vim.lsp.buf.code_action, "Code action")

  if supports_inlay_hints then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    set_lsp_keymap(bufnr, "<leader>ci", function()
      toggle_lsp_inlay_hints(bufnr)
    end, "Toggle inlay hints")
  end

  set_lsp_keymap(bufnr, "<leader>cr", vim.lsp.buf.rename, "Rename symbol")
end

local function register_lsp_attach_autocmd()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("RayLsp", { clear = true }),
    desc = "Configure LSP buffer keymaps",
    callback = configure_lsp_buffer,
  })
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
      update_in_insert = true,
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

    register_lsp_attach_autocmd()
  end,
}
