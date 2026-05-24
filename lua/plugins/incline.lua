local function filename(props)
  local name = vim.api.nvim_buf_get_name(props.buf)
  if name == "" then
    return "[No Name]"
  end

  return vim.fn.fnamemodify(name, ":t")
end

local function diagnostics(bufnr)
  local counts = vim.diagnostic.count(bufnr)
  local diagnostic_config = require("config.diagnostics")
  local severities = {
    vim.diagnostic.severity.ERROR,
    vim.diagnostic.severity.WARN,
    vim.diagnostic.severity.INFO,
    vim.diagnostic.severity.HINT,
  }
  local items = {}

  for _, severity in ipairs(severities) do
    local count = counts[severity] or 0
    if count > 0 then
      table.insert(
        items,
        { diagnostic_config.sign(severity) .. " " .. count .. " ", group = diagnostic_config.sign_group(severity) }
      )
    end
  end

  if #items > 0 then
    table.insert(items, { "┊ " })
  end

  return items
end

local function breadcrumbs(bufnr)
  local navic = require("nvim-navic")
  if not navic.is_available(bufnr) then
    return {}
  end

  local data = navic.get_data(bufnr)
  if not data or #data == 0 then
    return {}
  end

  local items = { { " ┊ ", group = "NavicSeparator" } }

  for index, item in ipairs(data) do
    if index > 1 then
      table.insert(items, { "  ", group = "NavicSeparator" })
    end
    table.insert(items, { item.icon, group = "NavicIcons" .. item.type })
    table.insert(items, { item.name, group = "NavicText" })
  end

  return items
end

return {
  "b0o/incline.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-mini/mini.nvim",
    "SmiteshP/nvim-navic",
  },
  config = function(_, opts)
    require("incline").setup(opts)

    vim.api.nvim_create_autocmd("DiagnosticChanged", {
      desc = "Refresh incline when diagnostics change",
      callback = function()
        vim.schedule(function()
          require("incline").refresh()
        end)
      end,
    })
  end,
  opts = {
    hide = {
      cursorline = "smart",
    },
    ignore = {
      buftypes = "special",
      filetypes = { "snacks_dashboard", "snacks_picker_list" },
      floating_wins = true,
      unlisted_buffers = true,
      wintypes = "special",
    },
    render = function(props)
      local name = filename(props)
      local icon, icon_hl = require("mini.icons").get("file", name), nil
      local modified = vim.bo[props.buf].modified

      return {
        diagnostics(props.buf),
        icon and { icon .. " ", group = icon_hl } or "",
        { name, gui = modified and "bold,italic" or "bold" },
        modified and { " +", guifg = "#a8a29e", gui = "bold" } or "",
        props.focused and breadcrumbs(props.buf) or {},
      }
    end,
    window = {
      margin = { horizontal = 1, vertical = 0 },
      padding = 1,
      placement = {
        horizontal = "right",
        vertical = "top",
      },
    },
  },
}
