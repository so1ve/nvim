local M = {}

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

local function statusline_path()
  local path = vim.api.nvim_buf_get_name(0)

  if path == "" then
    return ""
  end

  path = vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))

  local cwd = vim.fs.normalize(vim.fn.getcwd(0))
  local relative = vim.fs.relpath(cwd, path)

  return relative or path
end

local function statusline_fileinfo()
  local filetype = vim.bo.filetype

  if MiniStatusline.is_truncated(120) or vim.bo.buftype ~= "" then
    return filetype
  end

  if filetype == "" then
    return ""
  end

  local path = vim.api.nvim_buf_get_name(0)
  local icon = MiniIcons.get("file", path ~= "" and path or filetype)

  return string.format("%s %s", icon, filetype)
end

local function statusline_active()
  local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
  local git = MiniStatusline.section_git({ trunc_width = 40, icon = "" })
  local path = statusline_path()
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
    { hl = "MiniStatuslineFileinfo", strings = { statusline_section(path) } },
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
  local statusline_group = vim.api.nvim_create_augroup("RayStatusline", { clear = true })

  vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
    group = statusline_group,
    desc = "Redraw statusline when macro recording changes",
    callback = redraw_statusline,
  })

  vim.api.nvim_create_autocmd("User", {
    group = statusline_group,
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
