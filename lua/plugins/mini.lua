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

local function statusline_active()
  local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
  local git = MiniStatusline.section_git({ trunc_width = 40, icon = "" })
  local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
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

local function register_statusline_autocmds()
  local statusline_group = vim.api.nvim_create_augroup("RayStatusline", { clear = true })

  vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
    group = statusline_group,
    desc = "Redraw statusline when macro recording changes",
    callback = redraw_statusline,
  })

  vim.api.nvim_create_autocmd("User", {
    group = statusline_group,
    pattern = "GitSignsUpdate",
    desc = "Redraw statusline when Git signs data changes",
    callback = redraw_statusline,
  })
end

local function default_snippet_patterns(lang)
  return { lang .. "/**/*.json", lang .. "/**/*.lua", "**/" .. lang .. ".json", "**/" .. lang .. ".lua" }
end

local function snippet_patterns(lang, shared)
  local patterns = vim.list_extend({}, shared or {})

  vim.list_extend(patterns, default_snippet_patterns(lang))

  return patterns
end

return {
  "nvim-mini/mini.nvim",
  version = false,
  event = "VeryLazy",
  config = function()
    local icons = require("mini.icons")
    icons.setup()
    icons.mock_nvim_web_devicons()

    require("mini.ai").setup({ n_lines = 500 })
    require("mini.surround").setup()
    require("mini.pairs").setup()
    require("mini.comment").setup()
    require("mini.statusline").setup({
      content = {
        active = statusline_active,
        inactive = statusline_inactive,
      },
    })
    register_statusline_autocmds()
    require("mini.move").setup()
    require("mini.splitjoin").setup()
    require("mini.bracketed").setup({
      buffer = { suffix = "" },
      comment = { suffix = "" },
    })

    local snippets = require("mini.snippets")
    local gen_loader = snippets.gen_loader
    local javascript_snippets = { "shared/javascript.json" }
    snippets.setup({
      snippets = {
        gen_loader.from_file(vim.fn.stdpath("config") .. "/snippets/all.json"),
        gen_loader.from_lang({
          lang_patterns = {
            javascript = snippet_patterns("javascript", javascript_snippets),
            javascriptreact = snippet_patterns("javascriptreact", javascript_snippets),
            typescript = snippet_patterns("typescript", javascript_snippets),
            typescriptreact = snippet_patterns("typescriptreact", javascript_snippets),
            vue = snippet_patterns("vue", javascript_snippets),
          },
        }),
      },
      mappings = {
        expand = "",
        jump_next = "",
        jump_prev = "",
      },
    })

    local hipatterns = require("mini.hipatterns")
    hipatterns.setup({
      highlighters = {
        hex_color = hipatterns.gen_highlighter.hex_color(),
      },
    })

    require("mini.trailspace").setup()
  end,
}
