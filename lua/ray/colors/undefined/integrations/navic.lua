local M = {}
local styles = require("ray.colors.undefined.styles")

function M.get(p)
  local s = styles.get(p)

  return {
    NavicIconsFile = s.breadcrumb_kind.file,
    NavicIconsModule = s.breadcrumb_kind.module,
    NavicIconsNamespace = s.breadcrumb_kind.namespace,
    NavicIconsPackage = s.breadcrumb_kind.package,
    NavicIconsClass = s.breadcrumb_kind.class,
    NavicIconsMethod = s.breadcrumb_kind.method,
    NavicIconsProperty = s.breadcrumb_kind.property,
    NavicIconsField = s.breadcrumb_kind.field,
    NavicIconsConstructor = s.breadcrumb_kind.constructor,
    NavicIconsEnum = s.breadcrumb_kind.enum,
    NavicIconsInterface = s.breadcrumb_kind.interface,
    NavicIconsFunction = s.breadcrumb_kind.function_,
    NavicIconsVariable = s.breadcrumb_kind.variable,
    NavicIconsConstant = s.breadcrumb_kind.constant,
    NavicIconsString = s.breadcrumb_kind.string,
    NavicIconsNumber = s.breadcrumb_kind.number,
    NavicIconsBoolean = s.breadcrumb_kind.boolean,
    NavicIconsArray = s.breadcrumb_kind.array,
    NavicIconsObject = s.breadcrumb_kind.object,
    NavicIconsKey = s.breadcrumb_kind.key,
    NavicIconsNull = s.breadcrumb_kind.null,
    NavicIconsEnumMember = s.breadcrumb_kind.enum_member,
    NavicIconsStruct = s.breadcrumb_kind.struct,
    NavicIconsEvent = s.breadcrumb_kind.event,
    NavicIconsOperator = s.breadcrumb_kind.operator,
    NavicIconsTypeParameter = s.breadcrumb_kind.type_parameter,
    NavicText = s.dim,
    NavicSeparator = s.separator,
  }
end

return M
