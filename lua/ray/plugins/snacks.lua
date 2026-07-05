local function term_nav(direction)
  return function(win)
    if win:is_floating() then
      return "<C-" .. direction .. ">"
    end

    vim.schedule(function()
      vim.cmd.wincmd(direction)
    end)

    return ""
  end
end

local function greeting()
  local hour = tonumber(os.date("%H")) or 0

  if hour < 5 then
    return "Good Night, Ray"
  elseif hour < 12 then
    return "Good Morning, Ray"
  elseif hour < 18 then
    return "Good Afternoon, Ray"
  elseif hour < 22 then
    return "Good Evening, Ray"
  end

  return "Good Night, Ray"
end

local terminal = require("ray.config.terminal")
local edgy = require("ray.integrations.edgy")
local symbols = require("ray.config.symbols")

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "SnacksDashboardOpened",
        callback = function()
          vim.b.miniindentscope_disable = true
          vim.b.minicursorword_disable = true
          vim.o.laststatus = 3
          vim.wo.statusline = vim.go.statusline
          vim.cmd.redrawstatus()
        end,
      })
    end,
    opts = {
      bigfile = {},
      dashboard = {
        enabled = true,
        width = 54,
        preset = {
          header = greeting(),
          keys = {
            { key = "f", desc = "Find file", action = ":lua Snacks.picker.files()" },
            { key = "g", desc = "Find text", action = ":lua Snacks.picker.grep()" },
            { key = "r", desc = "Recent files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            {
              key = "G",
              desc = "Neogit",
              action = function()
                require("neogit").open()
              end,
            },
            {
              key = "l",
              desc = "Load session",
              action = function()
                require("ray.features.sessions").load()
              end,
            },
            { key = "q", desc = "Quit", action = ":qa" },
          },
        },
        formats = {
          header = { "%s", align = "left" },
        },
        sections = {
          { section = "header", padding = 1 },
          { title = "Commands", section = "keys", indent = 2, padding = 1 },
          { title = "Recent", section = "recent_files", indent = 2, padding = 1 },
          { title = "Projects", section = "projects", indent = 2, padding = 1 },
        },
      },
      quickfile = {},
      picker = {
        sources = {
          lsp_symbols = {
            filter = symbols.snacks_lsp_symbol_filter(),
          },
          lsp_workspace_symbols = {
            filter = symbols.snacks_lsp_symbol_filter(),
          },
        },
        actions = {
          trouble_open = function(picker)
            require("trouble.sources.snacks").open(picker)
          end,
          trouble_open_selected = function(picker)
            require("trouble.sources.snacks").open(picker, { type = "selected" })
          end,
          trouble_open_all = function(picker)
            require("trouble.sources.snacks").open(picker, { type = "all" })
          end,
        },
        win = {
          input = {
            keys = {
              ["<C-t>"] = { "trouble_open", mode = { "n", "i" } },
            },
          },
        },
      },
      input = {},
      notifier = {
        height = { min = 1, max = 0.4 },
      },
      styles = {
        notification = {
          ft = "snacks_notif",
        },
      },
      scroll = {
        filter = function(buf)
          return vim.g.snacks_scroll ~= false
            and vim.b[buf].snacks_scroll ~= false
            and vim.bo[buf].filetype == "snacks_picker_preview"
        end,
      },
      statuscolumn = {},
      terminal = {
        shell = terminal.shell.shell and { terminal.shell.shell, terminal.shell.flag } or nil,
        win = {
          keys = {
            nav_h = { "<C-h>", term_nav("h"), desc = "Move to left window", expr = true, mode = "t" },
            nav_j = { "<C-j>", term_nav("j"), desc = "Move to lower window", expr = true, mode = "t" },
            nav_k = { "<C-k>", term_nav("k"), desc = "Move to upper window", expr = true, mode = "t" },
            nav_l = { "<C-l>", term_nav("l"), desc = "Move to right window", expr = true, mode = "t" },
            paste = {
              "<C-v>",
              function()
                vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
              end,
              desc = "Paste from clipboard",
              mode = "t",
            },
          },
        },
      },
      gh = {},
      rename = {},
      words = { enabled = false },
    },
    keys = {
      {
        "<leader>gb",
        function()
          Snacks.picker.git_branches()
        end,
        desc = "Git branches",
      },
      {
        "<leader>gi",
        function()
          Snacks.picker.gh_issue()
        end,
        desc = "GitHub Issues (open)",
      },
      {
        "<leader>gI",
        function()
          Snacks.picker.gh_issue({ state = "all" })
        end,
        desc = "GitHub Issues (all)",
      },
      {
        "<leader>gp",
        function()
          Snacks.picker.gh_pr()
        end,
        desc = "GitHub Pull Requests (open)",
      },
      {
        "<leader>gP",
        function()
          Snacks.picker.gh_pr({ state = "all" })
        end,
        desc = "GitHub Pull Requests (all)",
      },
      {
        "<leader>ff",
        function()
          Snacks.picker.files()
        end,
        desc = "Find files",
      },
      {
        "<leader>fg",
        function()
          Snacks.picker.grep()
        end,
        desc = "Live grep",
      },
      {
        "<leader>fb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>fr",
        function()
          Snacks.picker.registers()
        end,
        desc = "Registers",
      },
      {
        "<leader>fu",
        function()
          Snacks.picker.undo()
        end,
        desc = "Undo history",
      },
      {
        "<leader>fd",
        function()
          Snacks.picker.diagnostics_buffer()
        end,
        desc = "Buffer diagnostics",
      },
      {
        "<leader>fD",
        function()
          Snacks.picker.diagnostics()
        end,
        desc = "Workspace diagnostics",
      },
      {
        "<leader>fk",
        function()
          Snacks.picker.keymaps()
        end,
        desc = "Keymaps",
      },
      {
        "<leader>fc",
        function()
          Snacks.picker.commands()
        end,
        desc = "Commands",
      },
      {
        "<leader>f:",
        function()
          Snacks.picker.command_history()
        end,
        desc = "Command history",
      },
      {
        "<leader>fl",
        function()
          local buf = vim.api.nvim_get_current_buf()

          Snacks.picker.pick({
            finder = function()
              local extmarks = require("snacks.picker.util.highlight").get_highlights({ buf = buf, extmarks = true })
              local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
              local items = {}

              for lnum, line in ipairs(lines) do
                items[#items + 1] = {
                  buf = buf,
                  text = line,
                  pos = { lnum, (line:find("%S") or 1) - 1 },
                  highlights = extmarks[lnum],
                }
              end

              return items
            end,
            format = "lines",
            title = "Buffer Lines",
            layout = {
              layout = {
                backdrop = 60,
              },
            },
          })
        end,
        desc = "Search current buffer",
      },
      {
        "<leader>f/",
        function()
          Snacks.picker.search_history()
        end,
        desc = "Search history",
      },
      {
        "<leader>nh",
        function()
          Snacks.picker.notifications()
        end,
        desc = "Notification history",
      },
      {
        "<leader>nd",
        function()
          Snacks.notifier.hide()
        end,
        desc = "Dismiss notifications",
      },
      {
        "<leader>fG",
        function()
          Snacks.picker.git_status()
        end,
        desc = "Git status",
      },
      {
        "<leader>tt",
        function()
          Snacks.terminal(nil, { count = 1, cwd = vim.fn.getcwd(0) })
        end,
        desc = "Toggle terminal",
      },
      {
        "<leader>cR",
        function()
          Snacks.rename.rename_file()
        end,
        desc = "Rename file",
      },
    },
  },
  edgy.view_spec(
    "bottom",
    edgy.view("Terminal", "snacks_terminal", {
      filter = function(_, win)
        local snacks_win = vim.w[win].snacks_win

        return snacks_win and snacks_win.position == "bottom" and snacks_win.relative == "editor"
      end,
    })
  ),
}
