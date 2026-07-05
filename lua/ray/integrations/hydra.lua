local columns = 3

local function pad(text, width)
  return text .. string.rep(" ", math.max(0, width - vim.api.nvim_strwidth(text)))
end

local function add_exit(heads)
  heads[#heads + 1] = { "q", nil, { exit = true, desc = "Quit", group = "Exit" } }
  heads[#heads + 1] = { "<Esc>", nil, { exit = true, desc = false } }
end

local function rows(heads)
  local result = {}
  local current

  for _, head in ipairs(heads) do
    local opts = head[3] or {}

    if opts.desc then
      if not current or current.group ~= opts.group or #current == columns then
        current = { group = opts.group }
        result[#result + 1] = current
      end

      current[#current + 1] = string.format("_%s_: %s", head[1], opts.desc)
    end
  end

  return result
end

local function hint(spec)
  local hint_rows = rows(spec.heads)
  local group_width = 0
  local widths = {}

  for _, row in ipairs(hint_rows) do
    group_width = math.max(group_width, vim.api.nvim_strwidth(row.group))

    for index, entry in ipairs(row) do
      widths[index] = math.max(widths[index] or 0, vim.api.nvim_strwidth(entry))
    end
  end

  local lines = { " " .. spec.name }
  local previous_group

  for _, row in ipairs(hint_rows) do
    local group = row.group == previous_group and "" or row.group

    for index, entry in ipairs(row) do
      row[index] = pad(entry, widths[index])
    end

    lines[#lines + 1] = " " .. pad(group, group_width) .. "  " .. table.concat(row, "  ")
    previous_group = row.group
  end

  return table.concat(lines, "\n") .. "\n"
end

return function(spec)
  add_exit(spec.heads)

  spec.config = vim.tbl_extend("force", spec.config or {}, {
    color = "pink",
    invoke_on_body = true,
    hint = {
      type = "window",
      position = "bottom",
      float_opts = {
        border = "rounded",
        zindex = 999,
      },
    },
  })
  spec.hint = hint(spec)

  for _, head in ipairs(spec.heads) do
    if head[3] then
      head[3].group = nil
    end
  end

  return require("hydra")(spec)
end
