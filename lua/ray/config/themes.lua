local M = {}

local default_theme = "undefined"
local state_file = vim.fn.stdpath("state") .. "/ray/theme"

local themes = {
  { name = "undefined", text = "Undefined", colorscheme = "undefined" },

  { name = "catppuccin", text = "Catppuccin", colorscheme = "catppuccin-nvim", plugin = "catppuccin" },
  { name = "catppuccin-latte", text = "Catppuccin Latte", colorscheme = "catppuccin-latte", plugin = "catppuccin" },
  { name = "catppuccin-frappe", text = "Catppuccin Frappé", colorscheme = "catppuccin-frappe", plugin = "catppuccin" },
  {
    name = "catppuccin-macchiato",
    text = "Catppuccin Macchiato",
    colorscheme = "catppuccin-macchiato",
    plugin = "catppuccin",
  },
  { name = "catppuccin-mocha", text = "Catppuccin Mocha", colorscheme = "catppuccin-mocha", plugin = "catppuccin" },

  { name = "nord", text = "Nord", colorscheme = "nord", plugin = "nord" },

  { name = "tokyonight", text = "Tokyo Night", colorscheme = "tokyonight", plugin = "tokyonight" },
  { name = "tokyonight-night", text = "Tokyo Night Night", colorscheme = "tokyonight-night", plugin = "tokyonight" },
  { name = "tokyonight-storm", text = "Tokyo Night Storm", colorscheme = "tokyonight-storm", plugin = "tokyonight" },
  { name = "tokyonight-moon", text = "Tokyo Night Moon", colorscheme = "tokyonight-moon", plugin = "tokyonight" },
  { name = "tokyonight-day", text = "Tokyo Night Day", colorscheme = "tokyonight-day", plugin = "tokyonight" },

  { name = "kanagawa", text = "Kanagawa", colorscheme = "kanagawa", plugin = "kanagawa" },
  { name = "kanagawa-wave", text = "Kanagawa Wave", colorscheme = "kanagawa-wave", plugin = "kanagawa" },
  { name = "kanagawa-dragon", text = "Kanagawa Dragon", colorscheme = "kanagawa-dragon", plugin = "kanagawa" },
  { name = "kanagawa-lotus", text = "Kanagawa Lotus", colorscheme = "kanagawa-lotus", plugin = "kanagawa" },

  { name = "rose-pine", text = "Rosé Pine", colorscheme = "rose-pine", plugin = "rose-pine" },
  { name = "rose-pine-moon", text = "Rosé Pine Moon", colorscheme = "rose-pine-moon", plugin = "rose-pine" },
  { name = "rose-pine-dawn", text = "Rosé Pine Dawn", colorscheme = "rose-pine-dawn", plugin = "rose-pine" },

  { name = "gruvbox", text = "Gruvbox", colorscheme = "gruvbox", plugin = "gruvbox" },

  {
    name = "everforest-soft",
    text = "Everforest Soft",
    colorscheme = "everforest",
    plugin = "everforest",
    before = function()
      require("everforest").setup({ background = "soft" })
    end,
  },
  {
    name = "everforest",
    text = "Everforest Medium",
    colorscheme = "everforest",
    plugin = "everforest",
    before = function()
      require("everforest").setup({ background = "medium" })
    end,
  },
  {
    name = "everforest-hard",
    text = "Everforest Hard",
    colorscheme = "everforest",
    plugin = "everforest",
    before = function()
      require("everforest").setup({ background = "hard" })
    end,
  },

  { name = "nightfox", text = "Nightfox", colorscheme = "nightfox", plugin = "nightfox" },
  { name = "dayfox", text = "Dayfox", colorscheme = "dayfox", plugin = "nightfox" },
  { name = "dawnfox", text = "Dawnfox", colorscheme = "dawnfox", plugin = "nightfox" },
  { name = "duskfox", text = "Duskfox", colorscheme = "duskfox", plugin = "nightfox" },
  { name = "nordfox", text = "Nordfox", colorscheme = "nordfox", plugin = "nightfox" },
  { name = "terafox", text = "Terafox", colorscheme = "terafox", plugin = "nightfox" },
  { name = "carbonfox", text = "Carbonfox", colorscheme = "carbonfox", plugin = "nightfox" },

  { name = "github-dark", text = "GitHub Dark", colorscheme = "github_dark", plugin = "github-theme" },
  {
    name = "github-dark-default",
    text = "GitHub Dark Default",
    colorscheme = "github_dark_default",
    plugin = "github-theme",
  },
  {
    name = "github-dark-dimmed",
    text = "GitHub Dark Dimmed",
    colorscheme = "github_dark_dimmed",
    plugin = "github-theme",
  },
  {
    name = "github-dark-high-contrast",
    text = "GitHub Dark High Contrast",
    colorscheme = "github_dark_high_contrast",
    plugin = "github-theme",
  },
  {
    name = "github-dark-colorblind",
    text = "GitHub Dark Colorblind",
    colorscheme = "github_dark_colorblind",
    plugin = "github-theme",
  },
  {
    name = "github-dark-tritanopia",
    text = "GitHub Dark Tritanopia",
    colorscheme = "github_dark_tritanopia",
    plugin = "github-theme",
  },
  { name = "github-light", text = "GitHub Light", colorscheme = "github_light", plugin = "github-theme" },
  {
    name = "github-light-default",
    text = "GitHub Light Default",
    colorscheme = "github_light_default",
    plugin = "github-theme",
  },
  {
    name = "github-light-high-contrast",
    text = "GitHub Light High Contrast",
    colorscheme = "github_light_high_contrast",
    plugin = "github-theme",
  },
  {
    name = "github-light-colorblind",
    text = "GitHub Light Colorblind",
    colorscheme = "github_light_colorblind",
    plugin = "github-theme",
  },
  {
    name = "github-light-tritanopia",
    text = "GitHub Light Tritanopia",
    colorscheme = "github_light_tritanopia",
    plugin = "github-theme",
  },

  {
    name = "oxocarbon",
    text = "Oxocarbon Dark",
    colorscheme = "oxocarbon",
    plugin = "oxocarbon",
    before = function()
      vim.o.background = "dark"
    end,
  },
  {
    name = "oxocarbon-light",
    text = "Oxocarbon Light",
    colorscheme = "oxocarbon",
    plugin = "oxocarbon",
    before = function()
      vim.o.background = "light"
    end,
  },
  {
    name = "melange",
    text = "Melange Dark",
    colorscheme = "melange",
    plugin = "melange",
    before = function()
      vim.o.background = "dark"
    end,
  },
  {
    name = "melange-light",
    text = "Melange Light",
    colorscheme = "melange",
    plugin = "melange",
    before = function()
      vim.o.background = "light"
    end,
  },
  {
    name = "material",
    text = "Material Oceanic",
    colorscheme = "material",
    plugin = "material",
    before = function()
      vim.g.material_style = "oceanic"
    end,
  },
  {
    name = "material-deep-ocean",
    text = "Material Deep Ocean",
    colorscheme = "material",
    plugin = "material",
    before = function()
      vim.g.material_style = "deep ocean"
    end,
  },
  {
    name = "material-palenight",
    text = "Material Palenight",
    colorscheme = "material",
    plugin = "material",
    before = function()
      vim.g.material_style = "palenight"
    end,
  },
  {
    name = "material-lighter",
    text = "Material Lighter",
    colorscheme = "material",
    plugin = "material",
    before = function()
      vim.g.material_style = "lighter"
    end,
  },
  {
    name = "material-darker",
    text = "Material Darker",
    colorscheme = "material",
    plugin = "material",
    before = function()
      vim.g.material_style = "darker"
    end,
  },
}

local theme_by_name = {}

for index, theme in ipairs(themes) do
  theme.index = index
  theme_by_name[theme.name] = theme
  theme_by_name[theme.colorscheme] = theme_by_name[theme.colorscheme] or theme
end

local function saved_theme_name()
  if vim.fn.filereadable(state_file) == 0 then
    return default_theme
  end

  return vim.trim(vim.fn.readfile(state_file)[1] or "")
end

function M.save(theme)
  vim.fn.mkdir(vim.fn.fnamemodify(state_file, ":h"), "p")
  vim.fn.writefile({ theme.name }, state_file)
end

function M.apply(name)
  local theme = theme_by_name[name or saved_theme_name()] or theme_by_name[default_theme]

  if theme.plugin then
    require("lazy").load({ plugins = { theme.plugin }, show = false })
  end

  if theme.before then
    theme.before()
  end

  vim.cmd.colorscheme(theme.colorscheme)
  vim.g.ray_theme = theme.name

  return theme
end

function M.select()
  local original = theme_by_name[vim.g.ray_theme] or theme_by_name[vim.g.colors_name] or theme_by_name[default_theme]
  local preview = original
  local confirmed = false

  Snacks.picker.pick({
    source = "ray_themes",
    title = "Colorscheme",
    finder = function()
      return themes
    end,
    format = "text",
    layout = { preset = "select" },
    on_show = function(picker)
      picker.list:view(original.index, nil, true)
    end,
    on_change = function(_, theme)
      if theme and theme ~= preview then
        preview = M.apply(theme.name)
      end
    end,
    confirm = function(picker, theme)
      if theme then
        M.save(M.apply(theme.name))
        confirmed = true
      end

      picker:close()
    end,
    on_close = function()
      if not confirmed then
        M.apply(original.name)
      end
    end,
  })
end

function M.complete(arglead)
  local matches = {}
  local query = arglead:lower()

  for _, theme in ipairs(themes) do
    if theme.name:find(query, 1, true) then
      matches[#matches + 1] = theme.name
    end
  end

  return matches
end

return M
