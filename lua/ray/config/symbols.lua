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

M.snacks_lsp_symbol_filter = {
  default = M.lsp_symbol_kinds,
  help = true,
  markdown = true,
}

M.trouble_lsp_symbol_filter = {
  ["not"] = { ft = "lua", kind = "Package" },
  any = {
    ft = { "help", "markdown" },
    kind = M.lsp_symbol_kinds,
  },
}

return M
