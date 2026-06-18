local diagnostic_icon = require("ray.config.diagnostics").sign(vim.diagnostic.severity.WARN)

local leader_groups = {
  { "<leader>b", group = "Buffer", icon = { icon = "󰈔", color = "cyan" } },
  { "<leader>c", group = "Code", icon = { icon = "󰅩", color = "azure" } },
  { "<leader>d", group = "Diagnostics", icon = { icon = diagnostic_icon, color = "yellow" } },
  { "<leader>f", group = "Find", icon = { icon = "󰍉", color = "blue" } },
  { "<leader>g", group = "Git", icon = { icon = "", color = "orange" } },
  { "<leader>gc", group = "Conflicts", icon = { icon = "", color = "red" } },
  { "<leader>m", group = "Multicursor", icon = { icon = "󰆿", color = "purple" } },
  { "<leader>n", group = "Noice", icon = { icon = "󰎟", color = "cyan" } },
  { "<leader>o", group = "Overseer", icon = { icon = "󰔟", color = "purple" } },
  { "<leader>a", group = "AI", icon = { icon = "󰚩", color = "green" } },
  { "<leader>p", group = "Project", icon = { icon = "", color = "blue" } },
  { "<leader>q", group = "Quit / Buffer / Window", icon = { icon = "󰈆", color = "red" } },
  { "<leader>r", group = "Refactor", icon = { icon = "󰑕", color = "purple" } },
  { "<leader>s", group = "Search", icon = { icon = "", color = "blue" } },
  { "<leader>t", group = "Terminal", icon = { icon = "", color = "green" } },
  { "<leader>T", group = "Test", icon = { icon = "󰙨", color = "green" } },
  { "<leader>u", group = "UI", icon = { icon = "󰙵", color = "cyan" } },
  { "<leader>x", group = "Trouble", icon = { icon = "", color = "red" } },
}

local surround_groups = {
  { "s", group = "Surround", mode = { "n", "x" }, icon = { icon = "󰅪", color = "purple" } },
}

local textobjects = {
  { "=", "assignment" },
  { "/", "comment" },
  { "F", "call" },
  { "a", "parameter" },
  { "b", "block" },
  { "c", "class" },
  { "f", "function" },
  { "i", "conditional" },
  { "r", "return" },
  { "s", "statement" },
  { "(", "() block" },
  { ")", "() block" },
  { "[", "[] block" },
  { "]", "[] block" },
  { "{", "{} block" },
  { "}", "{} block" },
  { "<", "<> block" },
  { ">", "<> block" },
  { '"', '" string' },
  { "'", "' string" },
  { "`", "` string" },
  { "q", "quote" },
  { "t", "tag" },
  { "w", "word" },
  { "W", "WORD" },
  { "p", "paragraph" },
}

local function textobject_groups()
  local groups = {
    mode = { "o", "x" },
    { "a", group = "around" },
    { "i", group = "inside" },
    { "an", group = "around next" },
    { "in", group = "inside next" },
    { "al", group = "around last" },
    { "il", group = "inside last" },
  }
  local prefixes = {
    { "a", "" },
    { "i", "inner " },
    { "an", "next " },
    { "in", "inner next " },
    { "al", "last " },
    { "il", "inner last " },
  }

  for _, prefix in ipairs(prefixes) do
    for _, object in ipairs(textobjects) do
      groups[#groups + 1] = { prefix[1] .. object[1], desc = prefix[2] .. object[2] }
    end
  end

  return groups
end

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    delay = 300,
    preset = "helix",
    plugins = {
      presets = {
        text_objects = false,
        nav = false,
      },
    },
    triggers = {
      { "<auto>", mode = { "n", "x", "s", "o" } },
      { "s", mode = { "n", "x" } },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer keymaps",
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add(leader_groups)
    wk.add(surround_groups)
    wk.add(textobject_groups())
  end,
}
