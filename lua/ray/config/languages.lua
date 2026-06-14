local modules = require("ray.utils.modules")

local M = {
  by_filetype = {},
  extensions = {},
  filetypes = {},
  language_filetypes = {},
  plugins = {},
  servers = {},
}

local MERGE_ORDER = { "languages", "filetypes", "servers", "plugins", "extend" }

local helpers = {}

function helpers.extend(config, key, values)
  local keys = vim.split(key, ".", { plain = true })
  local target = config

  for _, part in ipairs(keys) do
    target[part] = target[part] or {}
    target = target[part]
  end

  return vim.list_extend(target, values)
end

local function add_unique(target, seen, value)
  if value == nil or value == false or seen[value] then
    return
  end

  seen[value] = true
  table.insert(target, value)
end

local function add_entries(target, seen, entries)
  if type(entries) == "table" then
    for _, entry in ipairs(entries) do
      add_unique(target, seen, entry)
    end

    return
  end

  add_unique(target, seen, entries)
end

local function language_field(filetype, language, field, fallback)
  local value = language and language[field]

  if value ~= nil then
    return value
  end

  return fallback and fallback(filetype, language) or nil
end

local merge = {}

function merge.languages(languages)
  for filetype, language in pairs(languages or {}) do
    if not M.by_filetype[filetype] then
      table.insert(M.language_filetypes, filetype)
    end

    M.by_filetype[filetype] = language
  end
end

function merge.filetypes(filetypes)
  for group, rules in pairs(filetypes or {}) do
    M.filetypes[group] = M.filetypes[group] or {}

    for pattern, filetype in pairs(rules) do
      M.filetypes[group][pattern] = filetype
    end
  end
end

function merge.servers(servers)
  for server_name, server_config in pairs(servers or {}) do
    local current_config = M.servers[server_name]

    if current_config then
      M.servers[server_name] = vim.tbl_deep_extend("force", current_config, server_config)
    else
      M.servers[server_name] = server_config
    end
  end
end

function merge.plugins(plugins)
  vim.list_extend(M.plugins, plugins or {})
end

function merge.extend(extend)
  if extend then
    table.insert(M.extensions, extend)
  end
end

local MERGERS = {
  extend = merge.extend,
  filetypes = merge.filetypes,
  languages = merge.languages,
  plugins = merge.plugins,
  servers = merge.servers,
}

local function load_specs()
  for _, spec in ipairs(modules.load("ray.config.languages")) do
    for _, field in ipairs(MERGE_ORDER) do
      local value = spec[field]

      if value ~= nil then
        MERGERS[field](value)
      end
    end
  end

  table.sort(M.language_filetypes)
end

function M.collect(field, opts)
  opts = opts or {}

  local values = {}
  local seen = {}

  M.each_language(function(filetype, language)
    add_entries(values, seen, language_field(filetype, language, field, opts.fallback))
  end)

  add_entries(values, seen, opts.extra)

  return values
end

function M.each_language(callback)
  for _, filetype in ipairs(M.language_filetypes) do
    callback(filetype, M.by_filetype[filetype])
  end
end

function M.extend()
  for _, extend in ipairs(M.extensions) do
    extend(M, helpers)
  end

  return M
end

function M.get(filetype, field, fallback)
  if not filetype or filetype == "" then
    return nil
  end

  return language_field(filetype, M.by_filetype[filetype], field, fallback)
end

function M.map(field)
  local values = {}

  M.each_language(function(filetype, language)
    local value = language_field(filetype, language, field)

    if value ~= nil then
      values[filetype] = value
    end
  end)

  return values
end

function M.hover()
  local providers = M.get(vim.bo.filetype, "hover")

  if not providers then
    vim.lsp.buf.hover()

    return
  end

  -- require it here to make sure noice is loaded
  require("ray.patch.lsp.hover").show(providers)
end

load_specs()
M.extend()

return M
