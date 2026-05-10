local M = {}
local trunc_width = 120

local function statusline_escape(text)
  return tostring(text):gsub("%%", "%%%%")
end

local function statusline_section(section)
  if section == "" then
    return ""
  end

  return statusline_escape(section)
end

local function statusline_macro()
  local register = vim.fn.reg_recording()
  if register == "" then
    return ""
  end

  return statusline_escape("recording @" .. register)
end

local function statusline_location()
  return "%l/%L:%v"
end

local function statusline_pretty_path(max_parts)
  local path = vim.api.nvim_buf_get_name(0)

  if path == "" then
    return ""
  end

  path = vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))

  local cwd = vim.fs.normalize(vim.fn.getcwd(0))
  local relative = vim.fs.relpath(cwd, path)

  relative = (relative or path):gsub("\\", "/")

  local parts = vim.split(relative, "/", { plain = true })

  if #parts > max_parts then
    relative = table.concat({ parts[1], "..", parts[#parts - 1], parts[#parts] }, "/")
  end

  return relative
end

local function statusline_fileinfo()
  if MiniStatusline.is_truncated(trunc_width) or vim.bo.buftype ~= "" then
    return ""
  end

  local encoding = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding
  local format = vim.bo.fileformat

  return string.format("%s[%s]", encoding, format)
end

local function statusline_path_parts(path)
  local directory, filename = path:match("^(.*[/\\])([^/\\]+)$")

  if not filename then
    return "", path
  end

  return directory, filename
end

local function statusline_highlighted_path(path)
  local directory, filename = statusline_path_parts(path)

  if directory == "" then
    return "%#MiniStatuslineFilename#" .. statusline_section(filename)
  end

  return "%#MiniStatuslineDirectory#"
    .. statusline_section(directory)
    .. "%#MiniStatuslineFilename#"
    .. statusline_section(filename)
end

local function statusline_file()
  local path = vim.api.nvim_buf_get_name(0)

  if path == "" or vim.bo.buftype ~= "" then
    return ""
  end

  local icon, icon_hl = MiniIcons.get("file", path)
  local icon_part = "%#" .. icon_hl .. "#" .. statusline_escape(icon)

  if MiniStatusline.is_truncated(trunc_width) then
    return icon_part
  end

  local path_part = statusline_highlighted_path(statusline_pretty_path(3))

  return icon_part .. "%#MiniStatuslineFileinfo# " .. path_part
end

local function statusline_active()
  local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = trunc_width })
  local git = MiniStatusline.section_git({ trunc_width = 40, icon = "" })
  local file = statusline_file()
  local fileinfo = statusline_fileinfo()
  local search = MiniStatusline.section_searchcount({ trunc_width = 75, options = { recompute = false } })
  local location = statusline_location()

  return MiniStatusline.combine_groups({
    { hl = mode_hl, strings = { mode } },
    {
      hl = "MiniStatuslineDevinfo",
      strings = {
        statusline_section(git),
        statusline_macro(),
      },
    },
    "%<",
    { hl = "MiniStatuslineFileinfo", strings = { file } },
    "%=",
    { hl = "MiniStatuslineFileinfo", strings = { statusline_section(fileinfo) } },
    { hl = mode_hl, strings = { statusline_section(search), location } },
  })
end

local function statusline_inactive()
  return "%#MiniStatuslineInactive#%="
end

local function redraw_statusline()
  vim.schedule(function()
    vim.cmd.redrawstatus()
  end)
end

local function register_autocmds()
  vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
    desc = "Redraw statusline when macro recording changes",
    callback = redraw_statusline,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "GitSignsUpdate",
    desc = "Redraw statusline when Git head changes",
    callback = redraw_statusline,
  })
end

function M.setup()
  require("mini.statusline").setup({
    content = {
      active = statusline_active,
      inactive = statusline_inactive,
    },
  })
  register_autocmds()
end

return M
