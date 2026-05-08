local M = {}
local window_util = require("utils.windows")

local function sync_dashboard_tabline()
  local has_dashboard = false
  local has_work_file = false

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local bufnr = vim.api.nvim_win_get_buf(win)

    if window_util.is_dashboard(bufnr) then
      vim.b[bufnr].minitabline_disable = true
      has_dashboard = true
    elseif window_util.is_work_win(win) then
      has_work_file = true
    end
  end

  if has_dashboard and not has_work_file then
    vim.o.showtabline = 0

    return
  end

  vim.o.showtabline = 2
end

local function register_autocmds()
  local tabline_group = vim.api.nvim_create_augroup("RayTabline", { clear = true })

  vim.api.nvim_create_autocmd({ "BufEnter", "FileType", "WinEnter" }, {
    group = tabline_group,
    desc = "Hide mini.tabline while the dashboard is visible",
    callback = sync_dashboard_tabline,
  })

  sync_dashboard_tabline()
end

local function tabline_escape(text)
  return tostring(text):gsub("%%", "%%%%")
end

local function tabline_label(buf_id)
  local path = vim.api.nvim_buf_get_name(buf_id)

  if path == "" then
    return "[No Name]"
  end

  return vim.fn.fnamemodify(path, ":t")
end

local function tabline_state(buf_id)
  local state = buf_id == vim.api.nvim_get_current_buf() and "Current"
    or (vim.fn.bufwinnr(buf_id) > 0 and "Visible" or "Hidden")

  if vim.bo[buf_id].modified then
    state = "Modified" .. state
  end

  return state
end

local function tabline_icon(buf_id, is_current)
  local path = vim.api.nvim_buf_get_name(buf_id)
  local icon, icon_hl = MiniIcons.get("file", path ~= "" and path or tabline_label(buf_id))
  local icon_color = icon_hl:match("^MiniIcons(.+)$") or "Grey"
  local icon_state = is_current and "Current" or "Inactive"

  return "%#MiniTablineIcon" .. icon_color .. icon_state .. "#" .. tabline_escape(icon)
end

local function tabline_deduplicate_labels(tabs)
  local counts = {}

  for _, tab in ipairs(tabs) do
    counts[tab.label] = (counts[tab.label] or 0) + 1
  end

  for _, tab in ipairs(tabs) do
    if counts[tab.label] > 1 and tab.path ~= "" then
      tab.label = vim.fn.fnamemodify(tab.path, ":~:.")
    end
  end
end

function _G.RayTabline()
  local tabs = {}

  for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf_id].buflisted then
      table.insert(tabs, {
        buf_id = buf_id,
        label = tabline_label(buf_id),
        path = vim.api.nvim_buf_get_name(buf_id),
      })
    end
  end

  tabline_deduplicate_labels(tabs)

  local parts = {}

  for _, tab in ipairs(tabs) do
    local is_current = tab.buf_id == vim.api.nvim_get_current_buf()
    local state_hl = "MiniTabline" .. tabline_state(tab.buf_id)
    local indicator_hl = is_current and "MiniTablineFocusIndicator" or state_hl
    local indicator = is_current and "▎" or " "

    table.insert(parts, "%" .. tab.buf_id .. "@MiniTablineSwitchBuffer@")
    table.insert(parts, "%#" .. indicator_hl .. "#" .. indicator)
    table.insert(parts, "%#" .. state_hl .. "# ")
    table.insert(parts, tabline_icon(tab.buf_id, is_current))
    table.insert(parts, "%#" .. state_hl .. "# " .. tabline_escape(tab.label) .. "  ")
  end

  local tabline = table.concat(parts, "") .. "%X%#MiniTablineFill#"
  local tabpage_count = vim.fn.tabpagenr("$")

  if tabpage_count <= 1 or MiniTabline.config.tabpage_section == "none" then
    return tabline
  end

  local tabpage_section = string.format(" Tab %s/%s ", vim.fn.tabpagenr(), tabpage_count)

  if MiniTabline.config.tabpage_section == "right" then
    return tabline .. "%=%#MiniTablineTabpagesection#" .. tabpage_section
  end

  return "%#MiniTablineTabpagesection#" .. tabpage_section .. tabline
end

function M.setup()
  require("mini.tabline").setup()
  vim.o.tabline = "%!v:lua.RayTabline()"
  register_autocmds()
end

return M
