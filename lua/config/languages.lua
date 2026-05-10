local M = {}

local lsp = require("config.languages.lsp")
local modules = require("utils.modules")

local language_specs = modules.load("config.languages", { exclude = { "lsp" } })
local languages_by_filetype = {}
local language_filetypes = {}
local servers = {}
local language_plugins = {}
local server_extenders = {}

local function add_language(filetype, language)
  if not languages_by_filetype[filetype] then
    table.insert(language_filetypes, filetype)
  end

  languages_by_filetype[filetype] = language
end

local function add_unique(values, seen, value)
  if value == nil or value == false or seen[value] then
    return
  end

  seen[value] = true
  table.insert(values, value)
end

local function add_entries(values, seen, entries)
  if type(entries) == "table" then
    for _, entry in ipairs(entries) do
      add_unique(values, seen, entry)
    end

    return
  end

  add_unique(values, seen, entries)
end

for _, spec in ipairs(language_specs) do
  for filetype, language in pairs(spec.languages or {}) do
    add_language(filetype, language)
  end

  for server_name, server_config in pairs(spec.servers or {}) do
    local current_config = servers[server_name]

    if current_config then
      servers[server_name] = vim.tbl_deep_extend("force", current_config, server_config)
    else
      servers[server_name] = server_config
    end
  end

  if spec.extend then
    table.insert(server_extenders, spec.extend)
  end

  vim.list_extend(language_plugins, spec.plugins or {})
end

table.sort(language_filetypes)

for _, extend in ipairs(server_extenders) do
  extend(servers, lsp)
end

M.by_filetype = languages_by_filetype
M.plugins = language_plugins

function M.collect(field, opts)
  opts = opts or {}

  local values = {}
  local seen = {}

  for _, filetype in ipairs(language_filetypes) do
    local language = languages_by_filetype[filetype]
    local entries = language[field]

    if entries == nil and opts.fallback then
      entries = opts.fallback(filetype, language)
    end

    add_entries(values, seen, entries)
  end

  add_entries(values, seen, opts.extra)

  return values
end

function M.map(field)
  local values = {}

  for _, filetype in ipairs(language_filetypes) do
    local language = languages_by_filetype[filetype]

    if language[field] ~= nil then
      values[filetype] = language[field]
    end
  end

  return values
end

function M.get(filetype, field, fallback)
  if not filetype or filetype == "" then
    return nil
  end

  local language = languages_by_filetype[filetype]
  local value = language and language[field]

  if value ~= nil then
    return value
  end

  return fallback and fallback(filetype, language) or nil
end

function M.lsp_configs()
  local configs = {}

  for server_name, server_config in pairs(servers) do
    configs[server_name] = type(server_config) == "function" and server_config() or server_config
  end

  return configs
end

function M.hover()
  local providers = M.get(vim.bo.filetype, "hover")

  if not providers then
    vim.lsp.buf.hover()

    return
  end

  -- require it here to make sure noice is loaded
  require("patch.lsp.hover").show(providers)
end

return M
