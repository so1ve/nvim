local window_util = require("utils.windows")

local leader_clues = {
  { mode = "n", keys = "<Leader>c", desc = "+Code" },
  { mode = "n", keys = "<Leader>d", desc = "+Diagnostics" },
  { mode = "n", keys = "<Leader>f", desc = "+Find" },
  { mode = "n", keys = "<Leader>g", desc = "+Git" },
  { mode = "n", keys = "<Leader>gh", desc = "+Git hunk" },
  { mode = "n", keys = "<Leader>m", desc = "+Multicursor" },
  { mode = "n", keys = "<Leader>n", desc = "+Noice" },
  { mode = "n", keys = "<Leader>o", desc = "+AI" },
  { mode = "n", keys = "<Leader>r", desc = "+Refactor" },
  { mode = "n", keys = "<Leader>s", desc = "+Search" },
  { mode = "n", keys = "<Leader>t", desc = "+Terminal" },
  { mode = "n", keys = "<Leader>u", desc = "+UI" },
  { mode = "n", keys = "<Leader>x", desc = "+Trouble" },
  { mode = "n", keys = "<Leader>z", desc = "+Fold" },
}

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

local function register_tabline_autocmds()
  local tabline_group = vim.api.nvim_create_augroup("RayTabline", { clear = true })

  vim.api.nvim_create_autocmd({ "BufEnter", "FileType", "WinEnter" }, {
    group = tabline_group,
    desc = "Hide mini.tabline while the dashboard is visible",
    callback = sync_dashboard_tabline,
  })

  sync_dashboard_tabline()
end

local function setup_clue()
  local clue = require("mini.clue")

  clue.setup({
    clues = vim.list_extend(vim.deepcopy(leader_clues), {
      clue.gen_clues.square_brackets(),
      clue.gen_clues.builtin_completion(),
      clue.gen_clues.g(),
      clue.gen_clues.marks(),
      clue.gen_clues.registers(),
      clue.gen_clues.windows(),
      clue.gen_clues.z(),
    }),
    triggers = {
      { mode = { "n", "x" }, keys = "<Leader>" },
      { mode = "n", keys = "[" },
      { mode = "n", keys = "]" },
      { mode = "i", keys = "<C-x>" },
      { mode = { "n", "x" }, keys = "g" },
      { mode = { "n", "x" }, keys = "'" },
      { mode = { "n", "x" }, keys = "`" },
      { mode = { "n", "x" }, keys = '"' },
      { mode = { "i", "c" }, keys = "<C-r>" },
      { mode = "n", keys = "<C-w>" },
      { mode = { "n", "x" }, keys = "z" },
    },
    window = {
      delay = 300,
      config = {
        border = "rounded",
        width = "auto",
      },
    },
  })
end

local function default_snippet_patterns(lang)
  return { lang .. "/**/*.json", lang .. "/**/*.lua", "**/" .. lang .. ".json", "**/" .. lang .. ".lua" }
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
    require("mini.tabline").setup()
    register_tabline_autocmds()
    require("mini.move").setup()
    require("mini.splitjoin").setup()
    require("mini.bracketed").setup({
      comment = { suffix = "" },
    })

    local snippets = require("mini.snippets")
    local gen_loader = snippets.gen_loader
    local lang_patterns = {}

    local function add_snippet_file(path, langs)
      for _, lang in ipairs(langs) do
        lang_patterns[lang] = lang_patterns[lang] or default_snippet_patterns(lang)
        table.insert(lang_patterns[lang], 1, path)
      end

      return lang_patterns
    end

    add_snippet_file("shared/javascript.json", {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "vue",
    })

    snippets.setup({
      snippets = {
        gen_loader.from_file(vim.fn.stdpath("config") .. "/snippets/all.json"),
        gen_loader.from_lang({
          lang_patterns = lang_patterns,
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
    setup_clue()
  end,
}
