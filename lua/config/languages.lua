local M = {}

local lsp = require("config.languages.lsp")
local modules = require("utils.modules")

local language_specs = modules.load("config.languages", { exclude = { "lsp" } })
local servers = {}
local languages = {}
local language_plugins = {}
local edgy_views = { left = {}, right = {}, bottom = {} }
local extra_treesitter_parsers = {
  "bash",
  "lua",
  "markdown",
  "markdown_inline",
  "regex",
  "vim",
}
local server_extenders = {}

for _, spec in ipairs(language_specs) do
  for filetype, language in pairs(spec.languages or {}) do
    languages[filetype] = language
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

  for _, plugin in ipairs(spec.plugins or {}) do
    table.insert(language_plugins, plugin)
  end

  for position, views in pairs(spec.edgy or {}) do
    edgy_views[position] = edgy_views[position] or {}

    for _, view in ipairs(views) do
      table.insert(edgy_views[position], view)
    end
  end
end

for _, extend in ipairs(server_extenders) do
  extend(servers, lsp)
end

local function collect_language_entries(field)
  local names = {}
  local seen = {}

  for _, language in pairs(languages) do
    for _, name in ipairs(language[field] or {}) do
      if not seen[name] then
        seen[name] = true
        table.insert(names, name)
      end
    end
  end

  return names
end

local function collect_language_map(field)
  local values = {}

  for filetype, language in pairs(languages) do
    if language[field] then
      values[filetype] = language[field]
    end
  end

  return values
end

function M.treesitter_language(filetype)
  if filetype == "" then
    return nil
  end

  local language = languages[filetype]

  return language and language.treesitter or vim.treesitter.language.get_lang(filetype)
end

function M.treesitter_aliases()
  local aliases = {}

  for filetype, language in pairs(languages) do
    local parser = language.treesitter

    if parser and parser ~= filetype then
      aliases[parser] = aliases[parser] or {}
      table.insert(aliases[parser], filetype)
    end
  end

  return aliases
end

function M.lsp_configs()
  local configs = {}

  for server_name, server_config in pairs(servers) do
    configs[server_name] = type(server_config) == "function" and server_config() or server_config
  end

  return configs
end

function M.lsp_server_names()
  return collect_language_entries("lsp")
end

function M.tool_names()
  return collect_language_entries("tools")
end

function M.edgy_views()
  return edgy_views
end

function M.plugins()
  return language_plugins
end

function M.treesitter_parsers()
  local parsers = {}
  local seen = {}

  for filetype, language in pairs(languages) do
    local parser = language.treesitter or vim.treesitter.language.get_lang(filetype)

    if parser and not seen[parser] then
      seen[parser] = true
      table.insert(parsers, parser)
    end
  end

  for _, parser in ipairs(extra_treesitter_parsers) do
    if not seen[parser] then
      seen[parser] = true
      table.insert(parsers, parser)
    end
  end

  return parsers
end

function M.formatters_by_ft()
  return collect_language_map("formatters")
end

function M.linters_by_ft()
  return collect_language_map("linters")
end

function M.hover()
  local language = languages[vim.bo.filetype]
  local providers = language and language.hover

  if not providers then
    vim.lsp.buf.hover()

    return
  end

  -- require it here to make sure noice is loaded
  require("patch.lsp.hover").show(providers)
end

return M
