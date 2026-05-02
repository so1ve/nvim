local M = {}

function M.get(p)
  return {
    NavicIconsFile = { fg = p.blue },
    NavicIconsModule = { fg = p.magenta },
    NavicIconsNamespace = { fg = p.magenta },
    NavicIconsPackage = { fg = p.orange },
    NavicIconsClass = { fg = p.class },
    NavicIconsMethod = { fg = p.green },
    NavicIconsProperty = { fg = p.property },
    NavicIconsField = { fg = p.property },
    NavicIconsConstructor = { fg = p.green },
    NavicIconsEnum = { fg = p.number },
    NavicIconsInterface = { fg = p.interface },
    NavicIconsFunction = { fg = p.green },
    NavicIconsVariable = { fg = p.variable },
    NavicIconsConstant = { fg = p.constant },
    NavicIconsString = { fg = p.string },
    NavicIconsNumber = { fg = p.number },
    NavicIconsBoolean = { fg = p.boolean },
    NavicIconsArray = { fg = p.cyan },
    NavicIconsObject = { fg = p.cyan },
    NavicIconsKey = { fg = p.property },
    NavicIconsNull = { fg = p.muted },
    NavicIconsEnumMember = { fg = p.number },
    NavicIconsStruct = { fg = p.class },
    NavicIconsEvent = { fg = p.orange },
    NavicIconsOperator = { fg = p.operator },
    NavicIconsTypeParameter = { fg = p.interface },
    NavicText = { fg = p.fg_dim },
    NavicSeparator = { fg = p.subtle },
  }
end

return M
