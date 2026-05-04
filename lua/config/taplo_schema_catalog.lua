local M = {}

-- Taplo 0.10.0 rejects the current online SchemaStore catalog because the
-- catalog's `$schema` value changed from json.schemastore.org to
-- www.schemastore.org. Build a local compatibility copy from schemastore.nvim
-- so Taplo can keep using automatic catalog-based schema associations.
local function catalog_path()
  return vim.fs.joinpath(vim.fn.stdpath("cache"), "taplo", "schemastore-catalog.json")
end

function M.uri()
  local catalog = require("schemastore").json.load()
  local payload = {
    -- Keep the value Taplo 0.10.0 hard-codes while preserving the full
    -- schemastore.nvim schema list below. This is not Cargo-specific.
    ["$schema"] = "https://json.schemastore.org/schema-catalog.json",
    version = 1,
    schemas = catalog.schemas,
  }

  local encoded = vim.fn.json_encode(payload)
  local path = catalog_path()
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")

  local current = nil
  if vim.uv.fs_stat(path) then
    current = table.concat(vim.fn.readfile(path), "\n")
  end

  -- Avoid rewriting the cache file on every LSP startup when the generated
  -- payload is unchanged.
  if current ~= encoded then
    vim.fn.writefile({ encoded }, path)
  end

  return vim.uri_from_fname(path)
end

return M
