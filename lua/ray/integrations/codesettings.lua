local Control = require("codesettings.extensions").Control

local GOPLS_SETTING_GROUPS = {
  build = {},
  formatting = {},
  ui = {
    completion = {},
    diagnostic = {},
    documentation = {},
    inlayhint = {},
    navigation = {},
  },
}

local function promote_group(target, source, child_groups)
  if type(source) ~= "table" then
    return
  end

  for key, value in pairs(source) do
    if type(value) == "table" and child_groups[key] then
      promote_group(target, value, child_groups[key])
    elseif target[key] == nil then
      target[key] = value
    end
  end
end

local function promote_gopls_groups(root)
  local gopls = root.gopls

  if type(gopls) ~= "table" then
    return
  end

  for group, child_groups in pairs(GOPLS_SETTING_GROUPS) do
    promote_group(gopls, gopls[group], child_groups)
  end
end

return {
  object = function(root, context)
    if #context.path == 0 then
      promote_gopls_groups(root)
    end

    return Control.CONTINUE
  end,
}
