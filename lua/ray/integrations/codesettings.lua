local Control = require("codesettings.extensions").Control

local MAPPINGS = {
  { from = { "gopls", "formatting", "gofumpt" }, to = { "gopls", "gofumpt" } },
}

local function get(root, path)
  local node = root

  for _, key in ipairs(path) do
    if type(node) ~= "table" then
      return nil
    end

    node = node[key]
  end

  return node
end

local function set_missing(root, path, value)
  local node = root

  for index = 1, #path - 1 do
    local key = path[index]

    if type(node[key]) ~= "table" then
      node[key] = {}
    end

    node = node[key]
  end

  local leaf = path[#path]
  if node[leaf] == nil then
    node[leaf] = value
  end
end

local function apply_mappings(root)
  for _, mapping in ipairs(MAPPINGS) do
    local value = get(root, mapping.from)

    if value ~= nil then
      set_missing(root, mapping.to, value)
    end
  end
end

return {
  object = function(root, context)
    if #context.path == 0 then
      apply_mappings(root)
    end

    return Control.CONTINUE
  end,
}
