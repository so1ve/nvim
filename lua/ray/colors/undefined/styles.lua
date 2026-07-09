local M = {}

function M.get(p)
  -- Color contract:
  -- Green is the single theme accent: titles, focused popup/input borders, prompts, active chrome, and file/folder wayfinding.
  -- Blue is not a theme accent; keep it only for semantic info states and literal color categories.
  -- Border owns passive structure: separators and unfocused/generic float borders.
  local styles = {
    normal = { fg = p.fg, bg = p.bg },
    normal_nc = { fg = p.fg, bg = p.bg },
    dim = { fg = p.fg_dim },
    muted = { fg = p.muted },
    subtle = { fg = p.subtle },
    title = { fg = p.green, bold = true },
    key = { fg = p.orange, bold = true },
    separator = { fg = p.border },
    search = { fg = p.bg, bg = p.yellow },
    inc_search = { fg = p.bg, bg = p.orange },
    match = { fg = p.orange, bold = true },
    url = { fg = p.link, underline = true },
  }

  styles.float = {
    normal = { fg = p.fg, bg = p.bg },
    normal_nc = { fg = p.fg_dim, bg = p.bg },
    border = { fg = p.border, bg = p.bg },
    title = { fg = p.green, bg = p.bg, bold = true },
    separator = { fg = p.border, bg = p.bg },
    backdrop = { bg = p.bg_dark },
  }

  local function popup(bg)
    return {
      normal = { fg = p.fg, bg = bg },
      border = { fg = p.green, bg = bg },
      title = { fg = p.green, bg = bg, bold = true },
      border_search = { fg = p.yellow, bg = bg },
      selected = { bg = p.selection },
      progress_done = { fg = p.bg_dark, bg = p.green, bold = true },
      progress_todo = { fg = p.subtle, bg = p.selection },
    }
  end

  local function input(bg)
    return {
      normal = { fg = p.fg, bg = bg },
      border = { fg = p.green, bg = bg },
      title = { fg = p.green, bg = bg, bold = true },
      prompt = { fg = p.green },
    }
  end

  styles.popup = popup(p.bg_alt)
  styles.popup_editor = popup(p.bg)

  styles.input = input(p.bg_alt)
  styles.input_editor = input(p.bg)

  styles.message = {
    area = { fg = p.fg_dim },
    separator = { fg = p.border },
    error = { fg = p.red },
    warning = { fg = p.orange },
  }

  styles.statusline = {
    section = { fg = p.fg_dim, bg = p.bg_dark },
    inactive = { fg = p.subtle, bg = p.bg_dark },
    mode = function(color)
      return { fg = p.bg_dark, bg = color }
    end,
  }

  styles.tabline = {
    current = { fg = p.fg, bg = p.bg_alt, bold = true },
    visible = { fg = p.fg_dim, bg = p.bg_dark },
    hidden = { fg = p.muted, bg = p.bg_dark },
    fill = { fg = p.subtle, bg = p.bg_dark },
    focus_indicator = { fg = p.green, bg = p.bg_alt, bold = true },
    trunc = { fg = p.subtle, bg = p.bg_dark },
  }

  styles.diagnostic = {
    error = { fg = p.red },
    warn = { fg = p.orange },
    info = { fg = p.blue },
    hint = { fg = p.green },
    debug = { fg = p.magenta },
    trace = { fg = p.muted },
  }

  styles.diff = {
    add = { fg = p.diff_add_fg },
    change = { fg = p.diff_change_fg },
    delete = { fg = p.diff_delete_fg },
    add_bg = { bg = p.diff_add_bg },
    delete_bg = { bg = p.diff_delete_bg },
    add_inline = { fg = p.diff_add_fg, bg = p.diff_add_bg },
    delete_inline = { fg = p.diff_delete_fg, bg = p.diff_delete_bg },
  }

  styles.syntax = {
    comment = { fg = p.comment, italic = true },
    string = { fg = p.string },
    number = { fg = p.number },
    float = { fg = p.number },
    boolean = { fg = p.boolean },
    constant = { fg = p.constant },
    conditional = { fg = p.keyword, italic = true },
    repeat_ = { fg = p.keyword, italic = true },
    label = { fg = p.property },
    keyword = { fg = p.keyword, italic = true },
  }

  styles.kind = {
    text = { fg = p.fg },
    method = { fg = p.entity },
    function_ = { fg = p.entity },
    constructor = { fg = p.class },
    field = { fg = p.property },
    variable = { fg = p.variable },
    class = { fg = p.class },
    interface = { fg = p.interface },
    module = { fg = p.namespace },
    namespace = { fg = p.namespace },
    property = { fg = p.property },
    unit = { fg = p.number },
    value = { fg = p.constant },
    enum = { fg = p.class },
    keyword = { fg = p.keyword, italic = true },
    snippet = { fg = p.magenta },
    color = { fg = p.cyan },
    file = { fg = p.green },
    reference = { fg = p.link },
    folder = { fg = p.green },
    enum_member = { fg = p.constant },
    constant = { fg = p.constant },
    struct = { fg = p.class },
    event = { fg = p.orange },
    operator = { fg = p.operator },
    type_parameter = { fg = p.primitive },
    package = { fg = p.namespace },
    array = { fg = p.cyan },
    object = { fg = p.cyan },
    key = { fg = p.property },
    null = { fg = p.muted },
    number = { fg = p.number },
    boolean = { fg = p.boolean },
  }

  styles.breadcrumb_kind = {
    file = styles.kind.file,
    module = { fg = p.magenta },
    namespace = { fg = p.magenta },
    package = { fg = p.orange },
    class = styles.kind.class,
    method = { fg = p.green },
    property = styles.kind.property,
    field = styles.kind.field,
    constructor = { fg = p.green },
    enum = { fg = p.number },
    interface = styles.kind.interface,
    function_ = { fg = p.green },
    variable = styles.kind.variable,
    constant = styles.kind.constant,
    string = styles.syntax.string,
    number = styles.syntax.number,
    boolean = styles.syntax.boolean,
    array = styles.kind.array,
    object = styles.kind.object,
    key = styles.kind.key,
    null = styles.kind.null,
    enum_member = { fg = p.number },
    struct = styles.kind.struct,
    event = styles.kind.event,
    operator = styles.kind.operator,
    type_parameter = styles.kind.interface,
  }

  return styles
end

return M
