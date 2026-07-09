local utils = require("ray.utils")

local M = {
  by_filetype = {},
  extensions = {},
  filetypes = {},
  language_filetypes = {},
  plugins = {},
  servers = {},
}

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

local function language_field(filetype, language, field, fallback)
  local value = language and language[field]

  if value ~= nil then
    return value
  end

  return fallback and fallback(filetype, language) or nil
end

local function merge_languages(languages)
  for filetype, language in pairs(languages or {}) do
    if not M.by_filetype[filetype] then
      table.insert(M.language_filetypes, filetype)
    end

    M.by_filetype[filetype] = language
  end
end

local function merge_filetypes(filetypes)
  for group, rules in pairs(filetypes or {}) do
    M.filetypes[group] = M.filetypes[group] or {}

    for pattern, filetype in pairs(rules) do
      M.filetypes[group][pattern] = filetype
    end
  end
end

local function merge_servers(servers)
  for server_name, server_config in pairs(servers or {}) do
    local current_config = M.servers[server_name]

    M.servers[server_name] = current_config and vim.tbl_deep_extend("force", current_config, server_config)
      or server_config
  end
end

local function load_specs()
  for _, spec in ipairs(utils.load("ray.config.languages")) do
    merge_languages(spec.languages)
    merge_filetypes(spec.filetypes)
    merge_servers(spec.servers)
    vim.list_extend(M.plugins, spec.plugins or {})

    if spec.extend then
      table.insert(M.extensions, spec.extend)
    end
  end

  table.sort(M.language_filetypes)
end

function M.collect(field, opts)
  opts = opts or {}

  local values = {}
  local seen = {}

  local function add(value)
    if value ~= nil and value ~= false and not seen[value] then
      seen[value] = true
      table.insert(values, value)
    end
  end

  local function add_entries(entries)
    if type(entries) == "table" then
      for _, entry in ipairs(entries) do
        add(entry)
      end

      return
    end

    add(entries)
  end

  M.each_language(function(filetype, language)
    add_entries(language_field(filetype, language, field, opts.fallback))
  end)

  add_entries(opts.extra)

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
  return filetype and filetype ~= "" and language_field(filetype, M.by_filetype[filetype], field, fallback) or nil
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

load_specs()
M.extend()

return M
