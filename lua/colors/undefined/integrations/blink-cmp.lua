local M = {}
local styles = require("colors.undefined.styles")

function M.get(p)
  local s = styles.get(p)

  return {
    BlinkCmpLabel = { fg = p.fg },
    BlinkCmpLabelMatch = s.match,
    BlinkCmpLabelDeprecated = { fg = p.subtle, strikethrough = true },
    BlinkCmpLabelDetail = { fg = p.muted },
    BlinkCmpLabelDescription = { fg = p.comment },
    BlinkCmpSource = { fg = p.muted },
    BlinkCmpKind = { fg = p.green },
    BlinkCmpKindText = s.kind.text,
    BlinkCmpKindMethod = s.kind.method,
    BlinkCmpKindFunction = s.kind.function_,
    BlinkCmpKindConstructor = s.kind.constructor,
    BlinkCmpKindField = s.kind.field,
    BlinkCmpKindVariable = s.kind.variable,
    BlinkCmpKindClass = s.kind.class,
    BlinkCmpKindInterface = s.kind.interface,
    BlinkCmpKindModule = s.kind.module,
    BlinkCmpKindProperty = s.kind.property,
    BlinkCmpKindUnit = s.kind.unit,
    BlinkCmpKindValue = s.kind.value,
    BlinkCmpKindEnum = s.kind.enum,
    BlinkCmpKindKeyword = s.kind.keyword,
    BlinkCmpKindSnippet = s.kind.snippet,
    BlinkCmpKindColor = s.kind.color,
    BlinkCmpKindFile = s.kind.file,
    BlinkCmpKindReference = s.kind.reference,
    BlinkCmpKindFolder = s.kind.folder,
    BlinkCmpKindEnumMember = s.kind.enum_member,
    BlinkCmpKindConstant = s.kind.constant,
    BlinkCmpKindStruct = s.kind.struct,
    BlinkCmpKindEvent = s.kind.event,
    BlinkCmpKindOperator = s.kind.operator,
    BlinkCmpKindTypeParameter = s.kind.type_parameter,
    BlinkCmpScrollBarThumb = { bg = p.subtle },
    BlinkCmpScrollBarGutter = { bg = p.bg_alt },
    BlinkCmpGhostText = { fg = p.subtle },
    BlinkCmpMenu = s.popup.normal,
    BlinkCmpMenuBorder = s.popup.border,
    BlinkCmpMenuSelection = s.popup.selected,
    BlinkCmpDoc = s.float.normal,
    BlinkCmpDocBorder = s.float.border,
    BlinkCmpDocSeparator = s.float.border,
    BlinkCmpDocCursorLine = { bg = p.bg_alt },
    BlinkCmpSignatureHelp = s.float.normal,
    BlinkCmpSignatureHelpBorder = s.float.border,
    BlinkCmpSignatureHelpActiveParameter = { bg = p.selection, bold = true },
  }
end

return M
