local config = require("code-action-menu.config")

local M = {}

local kind_icons = {
  { "quickfix", "quickfix" },
  { "refactor.extract", "extract" },
  { "refactor.inline", "inline" },
  { "refactor.rewrite", "rewrite" },
  { "refactor", "refactor" },
  { "source.organizeImports", "organize_imports" },
  { "source", "source" },
}

local function kind_matches(kind, prefix)
  return kind == prefix or kind:sub(1, #prefix + 1) == prefix .. "."
end

local function icon_for_kind(kind, icons)
  kind = kind or ""

  for _, entry in ipairs(kind_icons) do
    if kind_matches(kind, entry[1]) then
      return icons[entry[2]]
    end
  end

  return icons.fallback
end

function M.from_action(action, client, bufnr)
  local opts = config.get()
  local title = action.title or action.command or "Code action"
  local client_name = client and client.name or "LSP"
  local icon = icon_for_kind(action.kind, opts.icons)

  return {
    action = action,
    client = client,
    client_name = client_name,
    bufnr = bufnr,
    icon = icon,
    kind = action.kind,
    source_text = string.format("[%s]", client_name),
    title = title,
    title_text = string.format("%s %s", icon, title),
  }
end

return M
