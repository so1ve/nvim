local M = {}

local function runtime_pattern(module)
  return "lua/" .. module:gsub("%.", "/") .. "/*.lua"
end

local function module_name(path)
  return (vim.fs.basename(path):gsub("%.lua$", ""))
end

local function exclude_set(excludes)
  local set = { init = true }

  for _, name in ipairs(excludes or {}) do
    set[name] = true
  end

  return set
end

function M.names(module, opts)
  opts = opts or {}

  local excluded = exclude_set(opts.exclude)
  local seen = {}
  local names = {}

  for _, path in ipairs(vim.api.nvim_get_runtime_file(runtime_pattern(module), true)) do
    local name = module_name(path)

    if not excluded[name] and not seen[name] then
      seen[name] = true
      table.insert(names, name)
    end
  end

  table.sort(names)

  return names
end

function M.load(module, opts)
  local loaded = {}

  for _, name in ipairs(M.names(module, opts)) do
    table.insert(loaded, require(module .. "." .. name))
  end

  return loaded
end

return M
