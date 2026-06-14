local M = {}

local severity_names = {
  [vim.diagnostic.severity.ERROR] = "Error",
  [vim.diagnostic.severity.WARN] = "Warn",
  [vim.diagnostic.severity.INFO] = "Info",
  [vim.diagnostic.severity.HINT] = "Hint",
}

M.signs = {
  [vim.diagnostic.severity.ERROR] = "",
  [vim.diagnostic.severity.WARN] = "",
  [vim.diagnostic.severity.INFO] = "",
  [vim.diagnostic.severity.HINT] = "󰌵",
}

local function diagnostic_format(diagnostic)
  local message = tostring(diagnostic.message or ""):gsub("\n", " \n")
  if not message:find("%S") then
    message = diagnostic.source or severity_names[diagnostic.severity] or "Diagnostic"
  end

  if diagnostic.code then
    return message
  end

  return message .. " "
end

local function map_float_navigation(bufnr)
  if not bufnr then
    return
  end

  vim.keymap.set("n", "j", "gj", { buffer = bufnr, desc = "Move down display line", silent = true })
  vim.keymap.set("n", "k", "gk", { buffer = bufnr, desc = "Move up display line", silent = true })
end

function M.sign(severity)
  local signs = vim.diagnostic.config().signs

  if type(signs) == "table" and type(signs.text) == "table" then
    return signs.text[severity] or "•"
  end

  return "•"
end

function M.sign_group(severity)
  return "DiagnosticSign" .. (severity_names[severity] or "Info")
end

function M.floating_group(severity)
  return "DiagnosticFloating" .. (severity_names[severity] or "Info")
end

function M.float_prefix(diagnostic)
  return " " .. M.sign(diagnostic.severity) .. " ", M.floating_group(diagnostic.severity)
end

function M.float_suffix(diagnostic)
  if not diagnostic.code then
    return ""
  end

  return " [" .. diagnostic.code .. "] ", "Comment"
end

function M.float_options()
  return {
    border = "rounded",
    close_events = { "BufHidden", "CursorMoved", "CursorMovedI", "InsertCharPre" },
    format = diagnostic_format,
    header = "",
    max_width = math.max(30, math.min(100, math.floor(vim.o.columns * 0.5))),
    prefix = M.float_prefix,
    source = "if_many",
    suffix = M.float_suffix,
  }
end

function M.open_float(opts)
  local bufnr, winid = vim.diagnostic.open_float(opts)
  map_float_navigation(bufnr)

  return bufnr, winid
end

function M.setup()
  vim.diagnostic.config({
    float = M.float_options,
    severity_sort = true,
    signs = {
      text = M.signs,
    },
    update_in_insert = false,
    virtual_text = false,
    virtual_lines = false,
  })
end

return M
