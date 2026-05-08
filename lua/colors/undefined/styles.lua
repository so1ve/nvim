local M = {}

local function copy(spec)
  local result = {}

  for key, value in pairs(spec or {}) do
    result[key] = value
  end

  return result
end

function M.extend(spec, overrides)
  local result = copy(spec)

  for key, value in pairs(overrides or {}) do
    result[key] = value
  end

  return result
end

function M.resolve_links(groups)
  local resolved = {}
  local resolving = {}

  local function resolve(group)
    if resolved[group] then
      return resolved[group]
    end

    local spec = groups[group]
    if not spec then
      return {}
    end

    if not spec.link then
      resolved[group] = spec

      return spec
    end

    if resolving[group] then
      return {}
    end

    resolving[group] = true

    local result = copy(resolve(spec.link))
    for key, value in pairs(spec) do
      if key ~= "link" then
        result[key] = value
      end
    end

    resolving[group] = nil
    resolved[group] = result

    return result
  end

  for group in pairs(groups) do
    groups[group] = resolve(group)
  end

  return groups
end

function M.get(p)
  local styles = {
    normal = { fg = p.fg, bg = p.bg },
    normal_nc = { fg = p.fg, bg = p.bg },
    dim = { fg = p.fg_dim },
    muted = { fg = p.muted },
    subtle = { fg = p.subtle },
    title = { fg = p.green, bold = true },
    key = { fg = p.orange, bold = true },
    separator = { fg = p.subtle },
    match = { fg = p.orange, bold = true },
    url = { fg = p.link, underline = true },
  }

  styles.float = {
    normal = { fg = p.fg, bg = p.bg },
    normal_nc = { fg = p.fg_dim, bg = p.bg },
    border = { fg = p.border, bg = p.bg },
    title = { fg = p.fg, bg = p.bg, bold = true },
    separator = { fg = p.border, bg = p.bg },
    backdrop = { bg = p.bg_dark },
  }

  styles.popup = {
    normal = { fg = p.fg, bg = p.bg_alt },
    border = { fg = p.blue, bg = p.bg_alt },
    title = { fg = p.blue, bg = p.bg_alt, bold = true },
    border_search = { fg = p.yellow, bg = p.bg_alt },
    selected = { fg = p.fg, bg = p.selection },
    progress_done = { fg = p.green, bg = p.bg_alt },
    progress_todo = { fg = p.subtle, bg = p.bg_alt },
  }

  styles.input = {
    normal = { fg = p.fg, bg = p.bg_alt },
    border = { fg = p.blue, bg = p.bg_alt },
    title = { fg = p.blue, bg = p.bg_alt, bold = true },
    prompt = { fg = p.green },
  }

  styles.message = {
    area = { fg = p.fg_dim, bg = p.bg_dark },
    separator = { fg = p.border, bg = p.bg_dark },
    error = { fg = p.red, bg = p.bg_dark },
    warning = { fg = p.orange, bg = p.bg_dark },
  }

  styles.statusline = {
    section = { fg = p.fg_dim, bg = p.bg_dark },
    inactive = { fg = p.subtle, bg = p.bg_dark },
    mode = function(color)
      return { fg = p.bg_dark, bg = color, bold = true }
    end,
  }

  styles.tabline = {
    current = { fg = p.fg, bg = p.bg_alt, bold = true },
    visible = { fg = p.fg_dim, bg = p.bg_dark },
    hidden = { fg = p.muted, bg = p.bg_dark },
    fill = { fg = p.subtle, bg = p.bg_dark },
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
    file = { fg = p.blue },
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
