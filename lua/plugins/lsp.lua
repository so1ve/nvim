local function server_defaults(opts)
  local capabilities = require("blink.cmp").get_lsp_capabilities(vim.lsp.protocol.make_client_capabilities())
  local servers = opts.servers or {}

  return vim.tbl_deep_extend("force", { capabilities = capabilities }, servers["*"] or {})
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

  local navic = require("nvim-navic")
  if supports_document_symbols and not navic.is_available(bufnr) then
    navic.attach(client, bufnr)
  end

  local function map(lhs, rhs, desc, opts)
    local keymap_opts = vim.tbl_extend("force", { buffer = bufnr, desc = desc }, opts or {})

    vim.keymap.set("n", lhs, rhs, keymap_opts)
  end

  map("K", function()
    require("config.languages").hover()
  end, "Hover documentation")
  map("gd", Snacks.picker.lsp_definitions, "Go to definition")
  map("gD", Snacks.picker.lsp_declarations, "Go to declaration")
  map("gI", Snacks.picker.lsp_implementations, "Go to implementation")
  map("gr", Snacks.picker.lsp_references, "References")
  map("gy", Snacks.picker.lsp_type_definitions, "Go to type definition")
  map("<leader>ca", function()
    require("code-action-menu").code_action()
  end, "Code action")

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

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "folke/noice.nvim", -- we patch noice's hover to make it work better with LSP
    "saghen/blink.cmp",
    "b0o/schemastore.nvim",
    "SmiteshP/nvim-navic",
  },
  opts = {
    servers = {
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
    },
  },
  config = function(_, opts)
    local languages = require("config.languages")

    vim.lsp.config("*", server_defaults(opts))

    for server_name, server_config in pairs(languages.lsp_configs()) do
      vim.lsp.config(server_name, server_config)
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "Configure LSP buffer keymaps",
      callback = configure_lsp_buffer,
    })
  end,
}
