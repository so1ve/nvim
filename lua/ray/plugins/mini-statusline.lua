local trunc_width = 120
local max_parts = 5
local copilot_status = ""
local copilot_status_registered = false

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

local function statusline_pretty_path()
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
    relative = table.concat({ parts[1], "…", parts[#parts - 1], parts[#parts] }, "/")
  end

  return relative
end

local function statusline_metadata()
  if MiniStatusline.is_truncated(trunc_width) or vim.bo.buftype ~= "" then
    return ""
  end

  local encoding = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding
  local format = vim.bo.fileformat

  return string.format("%s[%s]", encoding, format)
end

local function statusline_highlight(hl, text)
  return "%#" .. hl .. "#" .. statusline_section(text)
end

local function statusline_git()
  if MiniStatusline.is_truncated(40) then
    return ""
  end

  local summary = vim.b.minigit_summary

  if not summary or not summary.head_name then
    return ""
  end

  local head = summary.head_name == "HEAD" and summary.head:sub(1, 7) or summary.head_name
  local in_progress = summary.in_progress

  if in_progress and in_progress ~= "" then
    head = head .. "|" .. in_progress
  end

  return statusline_section(" " .. head)
end

local function statusline_diff()
  if MiniStatusline.is_truncated(75) or type(vim.b.minidiff_summary) ~= "table" then
    return ""
  end

  local summary = vim.b.minidiff_summary
  local parts = {}

  if (summary.add or 0) > 0 then
    table.insert(parts, statusline_highlight("MiniStatuslineDiffAdd", "+" .. summary.add))
  end

  if (summary.change or 0) > 0 then
    table.insert(parts, statusline_highlight("MiniStatuslineDiffChange", "~" .. summary.change))
  end

  if (summary.delete or 0) > 0 then
    table.insert(parts, statusline_highlight("MiniStatuslineDiffDelete", "-" .. summary.delete))
  end

  if #parts == 0 then
    return ""
  end

  return table.concat(parts, " ") .. "%#MiniStatuslineDevinfo#"
end

local function statusline_copilot()
  return statusline_section(copilot_status == "InProgress" and "" or "")
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

  local path_part = statusline_highlighted_path(statusline_pretty_path())

  return icon_part .. "%#MiniStatuslinePath# " .. path_part
end

local function statusline_active()
  local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = trunc_width })
  local git = statusline_git()
  local diff = statusline_diff()
  local file = statusline_file()
  local metadata = statusline_metadata()
  local search = MiniStatusline.section_searchcount({ trunc_width = 75, options = { recompute = false } })

  return MiniStatusline.combine_groups({
    { hl = mode_hl, strings = { mode } },
    { hl = "MiniStatuslineDevinfo", strings = { git, diff } },
    "%<",
    { hl = "MiniStatuslinePath", strings = { file } },
    "%=",
    { hl = "MiniStatuslineInputState", strings = { statusline_macro(), "%S" } },
    { hl = "MiniStatuslineInputState", strings = { statusline_copilot() } },
    { hl = "MiniStatuslineMetadata", strings = { statusline_section(metadata) } },
    { hl = mode_hl, strings = { statusline_section(search), "%l/%L:%v" } },
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

local function setup_copilot_status()
  if copilot_status_registered then
    return
  end

  local ok, status = pcall(require, "copilot.status")
  if not ok then
    return
  end

  if type(status) ~= "table" or type(status.register_status_notification_handler) ~= "function" then
    return
  end

  local function update_copilot_status(data)
    copilot_status = type(data) == "table" and data.status or ""
    redraw_statusline()
  end

  local registered = pcall(status.register_status_notification_handler, update_copilot_status)
  if registered then
    copilot_status_registered = true
  end
end

return {
  "mini.statusline",
  virtual = true,
  dependencies = { "nvim-mini/mini.nvim" },
  event = "UIEnter",
  config = function()
    require("mini.statusline").setup({
      content = {
        active = statusline_active,
        inactive = statusline_inactive,
      },
    })

    vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
      callback = redraw_statusline,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = { "MiniDiffUpdated", "MiniGitUpdated" },
      callback = redraw_statusline,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(args)
        if args.data == "copilot.lua" then
          setup_copilot_status()
        end
      end,
    })

    if package.loaded["copilot.status"] ~= nil then
      setup_copilot_status()
    end
  end,
}
