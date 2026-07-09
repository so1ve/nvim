local M = {}

function M.extend(...)
  return vim.tbl_extend("force", ...)
end

function M.load(module)
  local loaded = {}

  for _, path in ipairs(vim.api.nvim_get_runtime_file("lua/" .. module:gsub("%.", "/") .. "/*.lua", true)) do
    local name = vim.fs.basename(path):gsub("%.lua$", "")

    if name ~= "init" then
      table.insert(loaded, require(module .. "." .. name))
    end
  end

  return loaded
end

return M
