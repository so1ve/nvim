local M = {}

M.lsp_symbol_kinds = {
  "Class",
  "Constant",
  "Constructor",
  "Enum",
  "EnumMember",
  "Field",
  "Function",
  "Interface",
  "Method",
  "Module",
  "Namespace",
  "Package",
  "Property",
  "Struct",
  "Trait",
  "TypeParameter",
  "Variable",
}

function M.snacks_lsp_symbol_filter()
  return {
    default = vim.deepcopy(M.lsp_symbol_kinds),
    help = true,
    markdown = true,
  }
end

function M.trouble_lsp_symbol_filter()
  return {
    ["not"] = { ft = "lua", kind = "Package" },
    any = {
      ft = { "help", "markdown" },
      kind = vim.deepcopy(M.lsp_symbol_kinds),
    },
  }
end

return M
