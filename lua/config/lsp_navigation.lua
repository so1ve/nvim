local M = {}

function M.definitions()
  Snacks.picker.lsp_definitions()
end

function M.declarations()
  Snacks.picker.lsp_declarations()
end

function M.implementations()
  Snacks.picker.lsp_implementations()
end

function M.references()
  Snacks.picker.lsp_references()
end

function M.type_definitions()
  Snacks.picker.lsp_type_definitions()
end

return M
