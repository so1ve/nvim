return {
  "nvim-mini/mini.nvim",
  lazy = false,
  priority = 1000,
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  config = function()
    local excluded_filetypes = {
      "bigfile",
      "gitcommit",
      "help",
      "markdown",
    }

    do
      -- clue
      local clue = require("mini.clue")
      local gen_clues = clue.gen_clues

      local objects = {
        { "=", "assignment" },
        { "/", "comment" },
        { "B", "buffer" },
        { "F", "call" },
        { "I", "indent" },
        { "a", "argument" },
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

      local object_prefixes = {
        { "a", "around " },
        { "i", "inside " },
        { "an", "around next " },
        { "in", "inside next " },
        { "al", "around last " },
        { "il", "inside last " },
      }

      local operator_targets = {
        { "w", "word" },
        { "W", "WORD" },
        { "$", "to line end" },
        { "0", "to line start" },
        { "^", "to first non-blank" },
        { "gg", "to file start" },
        { "G", "to file end" },
        { "%", "matching pair" },
        { "/", "search forward" },
        { "?", "search backward" },
        { "f", "find char forward" },
        { "F", "find char backward" },
        { "t", "till char forward" },
        { "T", "till char backward" },
      }

      local generated_clues = {
        { mode = { "o", "x" }, keys = "a", desc = "+Around" },
        { mode = { "o", "x" }, keys = "i", desc = "+Inside" },
        { mode = { "o", "x" }, keys = "an", desc = "+Around next" },
        { mode = { "o", "x" }, keys = "in", desc = "+Inside next" },
        { mode = { "o", "x" }, keys = "al", desc = "+Around last" },
        { mode = { "o", "x" }, keys = "il", desc = "+Inside last" },
      }

      for _, prefix in ipairs(object_prefixes) do
        for _, object in ipairs(objects) do
          generated_clues[#generated_clues + 1] =
            { mode = { "o", "x" }, keys = prefix[1] .. object[1], desc = prefix[2] .. object[2] }
        end
      end

      local operators = {
        { "d", "Delete" },
        { "y", "Yank" },
        { "c", "Change" },
      }

      for _, operator in ipairs(operators) do
        local key = operator[1]
        local action = operator[2]

        generated_clues[#generated_clues + 1] = { mode = "n", keys = key, desc = "+" .. action }
        generated_clues[#generated_clues + 1] = { mode = "n", keys = key .. key, desc = "line" }

        for _, target in ipairs(operator_targets) do
          generated_clues[#generated_clues + 1] = { mode = "n", keys = key .. target[1], desc = target[2] }
        end

        for _, prefix in ipairs(object_prefixes) do
          generated_clues[#generated_clues + 1] =
            { mode = "n", keys = key .. prefix[1], desc = "+" .. prefix[2] .. "textobject" }

          for _, object in ipairs(objects) do
            generated_clues[#generated_clues + 1] = {
              mode = "n",
              keys = key .. prefix[1] .. object[1],
              desc = prefix[2] .. object[2],
            }
          end
        end
      end

      clue.setup({
        triggers = {
          { mode = { "n", "x" }, keys = "<Leader>" },
          { mode = "n", keys = "d" },
          { mode = "n", keys = "y" },
          { mode = "n", keys = "c" },
          { mode = { "o", "x" }, keys = "a" },
          { mode = { "o", "x" }, keys = "i" },
          { mode = { "n", "x" }, keys = "g" },
          { mode = { "n", "x" }, keys = "z" },
          { mode = "n", keys = "<C-w>" },
          { mode = "n", keys = "[" },
          { mode = "n", keys = "]" },
          { mode = { "n", "x" }, keys = "'" },
          { mode = { "n", "x" }, keys = "`" },
          { mode = { "n", "x" }, keys = '"' },
          { mode = "i", keys = "<C-x>" },
          { mode = { "i", "c" }, keys = "<C-r>" },
          { mode = { "n", "x" }, keys = "s" },
        },
        clues = {
          { mode = "n", keys = "<Leader>a", desc = "+AI" },
          { mode = "n", keys = "<Leader>b", desc = "+Buffer" },
          { mode = "n", keys = "<Leader>c", desc = "+Code" },
          { mode = "n", keys = "<Leader>d", desc = "+Diagnostics" },
          { mode = "n", keys = "<Leader>f", desc = "+Find" },
          { mode = "n", keys = "<Leader>g", desc = "+Git" },
          { mode = "n", keys = "<Leader>gc", desc = "+Conflicts" },
          { mode = "n", keys = "<Leader>gcn", desc = "Next", postkeys = "<Leader>gc" },
          { mode = "n", keys = "<Leader>gcp", desc = "Previous", postkeys = "<Leader>gc" },
          { mode = "n", keys = "<Leader>gcr", desc = "Refresh", postkeys = "<Leader>gc" },
          { mode = "n", keys = "<Leader>gcc", desc = "Accept current", postkeys = "<Leader>gc" },
          { mode = "n", keys = "<Leader>gci", desc = "Accept incoming", postkeys = "<Leader>gc" },
          { mode = "n", keys = "<Leader>gcB", desc = "Accept both", postkeys = "<Leader>gc" },
          { mode = "n", keys = "<Leader>gcb", desc = "Accept base", postkeys = "<Leader>gc" },
          { mode = "n", keys = "<Leader>gcl", desc = "Files" },
          { mode = "n", keys = "<Leader>gcQ", desc = "Quickfix" },
          { mode = "n", keys = "<Leader>m", desc = "+Multicursor" },
          { mode = { "n", "x" }, keys = "<Leader>m<C-j>", desc = "Add cursor down", postkeys = "<Leader>m" },
          { mode = { "n", "x" }, keys = "<Leader>m<C-k>", desc = "Add cursor up", postkeys = "<Leader>m" },
          { mode = { "n", "x" }, keys = "<Leader>ma", desc = "Add all matches" },
          { mode = "n", keys = "<Leader>n", desc = "+Notifications" },
          { mode = "n", keys = "<Leader>p", desc = "+Project" },
          { mode = "n", keys = "<Leader>q", desc = "+Quit / Buffer / Window" },
          { mode = "n", keys = "<Leader>r", desc = "+Refactor" },
          { mode = "n", keys = "<Leader>s", desc = "+Search" },
          { mode = "n", keys = "<Leader>t", desc = "+Terminal" },
          { mode = "n", keys = "<Leader>T", desc = "+Test" },
          { mode = "n", keys = "<Leader>Tr", desc = "Run nearest", postkeys = "<Leader>T" },
          { mode = "n", keys = "<Leader>Tt", desc = "Run file", postkeys = "<Leader>T" },
          { mode = "n", keys = "<Leader>TT", desc = "Run all files", postkeys = "<Leader>T" },
          { mode = "n", keys = "<Leader>Tl", desc = "Run last", postkeys = "<Leader>T" },
          { mode = "n", keys = "<Leader>Ts", desc = "Summary" },
          { mode = "n", keys = "<Leader>To", desc = "Output" },
          { mode = "n", keys = "<Leader>TO", desc = "Output panel" },
          { mode = "n", keys = "<Leader>Ta", desc = "Attach" },
          { mode = "n", keys = "<Leader>Tw", desc = "Watch file", postkeys = "<Leader>T" },
          { mode = "n", keys = "<Leader>TS", desc = "Stop", postkeys = "<Leader>T" },
          { mode = "n", keys = "<Leader>Td", desc = "Debug nearest" },
          { mode = "n", keys = "<Leader>u", desc = "+UI" },
          { mode = "n", keys = "<Leader>x", desc = "+Trouble" },
          { mode = { "n", "x" }, keys = "<Leader>y", desc = "+Yank/Paste" },
          { mode = { "n", "x" }, keys = "s", desc = "+Surround" },

          gen_clues.builtin_completion(),
          generated_clues,
          gen_clues.g(),
          gen_clues.marks(),
          gen_clues.registers(),
          gen_clues.windows({
            submode_move = true,
            submode_navigate = true,
            submode_resize = true,
          }),
          gen_clues.square_brackets(),
          gen_clues.z(),
        },
        window = {
          delay = 300,
          config = {
            width = "auto",
          },
        },
      })
    end

    do
      -- diff
      local diff = require("mini.diff")

      diff.setup({
        view = {
          style = "sign",
          signs = { add = "▌", change = "▌", delete = "▌" },
        },
        mappings = {
          apply = "gh",
          reset = "gH",
          textobject = "gh",
          goto_first = "[C",
          goto_prev = "[c",
          goto_next = "]c",
          goto_last = "]C",
        },
      })

      vim.keymap.set("n", "<leader>go", function()
        diff.toggle_overlay(0)
      end, { desc = "Toggle diff overlay" })

      vim.keymap.set("n", "<leader>gh", function()
        local hunks = diff.export("qf", { scope = "current" })

        if #hunks == 0 then
          vim.notify("No hunks in current file", vim.log.levels.INFO)

          return
        end

        vim.fn.setqflist(hunks, "r")
        vim.cmd.copen()
      end, { desc = "Current file hunks" })
    end

    do
      -- essential
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWinEnter", "FileType" }, {
        callback = function(event)
          local buf = event.buf
          if not vim.api.nvim_buf_is_valid(buf) then
            return
          end

          if vim.bo[buf].buftype ~= "" or vim.tbl_contains(excluded_filetypes, vim.bo[buf].filetype) then
            vim.b[buf].miniindentscope_disable = true
            vim.b[buf].minicursorword_disable = true
          end
        end,
      })

      local icons = require("mini.icons")
      icons.setup()
      icons.mock_nvim_web_devicons()

      local ai = require("mini.ai")
      local gen_ai_spec = require("mini.extra").gen_ai_spec
      local ts = ai.gen_spec.treesitter
      ai.setup({
        n_lines = 500,
        search_method = "cover",
        custom_textobjects = {
          ["="] = ts({ a = "@assignment.outer", i = "@assignment.inner" }),
          ["/"] = ts({ a = "@comment.outer", i = "@comment.inner" }),
          B = gen_ai_spec.buffer(),
          F = ts({ a = "@call.outer", i = "@call.inner" }),
          I = gen_ai_spec.indent(),
          a = ts({ a = "@parameter.outer", i = "@parameter.inner" }),
          b = ts({ a = "@block.outer", i = "@block.inner" }),
          c = ts({ a = "@class.outer", i = "@class.inner" }),
          f = ts({ a = "@function.outer", i = "@function.inner" }),
          i = ts({ a = "@conditional.outer", i = "@conditional.inner" }),
          r = ts({ a = "@return.outer", i = "@return.inner" }),
          -- intentional: use outer for both because inner is not consistent across languages
          s = ts({ a = "@statement.outer", i = "@statement.outer" }),
        },
      })

      require("mini.git").setup()
      require("mini.align").setup()
      require("mini.pairs").setup({
        mappings = {
          ['"'] = false,
          ["'"] = false,
          ["`"] = false,
        },
      })
      require("mini.surround").setup()
      require("mini.jump").setup()
      require("mini.cursorword").setup({ delay = 0 })
      require("mini.indentscope").setup({
        symbol = "│",
        draw = {
          animation = function()
            return 8
          end,
        },
        mappings = {
          object_scope = "",
          object_scope_with_border = "",
          goto_top = "",
          goto_bottom = "",
        },
      })

      local jump2d = require("mini.jump2d")
      local spotter =
        jump2d.gen_spotter.union(jump2d.builtin_opts.word_start.spotter, jump2d.gen_spotter.pattern(".+", "end"))
      jump2d.setup({
        spotter = spotter,
        labels = "abcdefghijklmnopqrstuvwxyz",
        view = { n_steps_ahead = 2 },
        allowed_windows = { not_current = false },
        mappings = { start_jumping = "<leader>j" },
      })

      require("mini.move").setup()
      require("mini.operators").setup({
        exchange = { prefix = "gX" },
        replace = { prefix = "gR" },
        sort = { prefix = "" },
      })
      require("mini.misc").setup_restore_cursor()
      require("mini.trailspace").setup()
      require("mini.bracketed").setup({
        buffer = { suffix = "" },
        comment = { suffix = "" },
        file = { suffix = "" },
        treesitter = { suffix = "" },
      })
    end

    do
      -- files
      local ignore = require("ray.config.ignore")
      local show_hidden = false

      local files = require("mini.files")

      local opts = {
        content = {
          filter = function(entry)
            return show_hidden or not ignore.is_ignored(entry.path or entry.name)
          end,
          highlight = function(entry)
            if ignore.is_ignored(entry.path or entry.name) then
              return "MiniFilesHidden"
            end

            return files.default_highlight(entry)
          end,
        },
        mappings = {
          go_in = "L",
          go_in_plus = "<C-l>",
          go_out = "H",
          go_out_plus = "<C-h>",
          synchronize = "s",
        },
        options = {
          lsp_timeout = 0,
        },
        windows = {
          preview = true,
          width_preview = 40,
        },
      }

      files.setup(opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          vim.keymap.set("n", "<CR>", function()
            files.go_in({ close_on_file = true })
          end, { buffer = args.data.buf_id, desc = "Go in plus" })
          vim.keymap.set("n", "J", "j", { buffer = args.data.buf_id, desc = "Move down" })
          vim.keymap.set("n", "K", "k", { buffer = args.data.buf_id, desc = "Move up" })
          vim.keymap.set("n", "gh", function()
            show_hidden = not show_hidden
            files.refresh(opts)
          end, { buffer = args.data.buf_id, desc = "Toggle hidden entries" })
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "RayGitIgnoreCacheUpdated",
        callback = function()
          files.refresh(opts)
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = { "MiniFilesActionRename", "MiniFilesActionMove" },
        callback = function(event)
          Snacks.rename.on_rename_file(vim.fs.normalize(event.data.from), vim.fs.normalize(event.data.to))
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesActionDelete",
        callback = function(event)
          Snacks.bufdelete({ file = vim.fs.normalize(event.data.from) })
        end,
      })

      vim.keymap.set("n", "<leader>e", function()
        files.close()
        files.open(vim.fn.getcwd(), false)
      end, { desc = "Explore files" })
      vim.keymap.set("n", "<leader>E", function()
        files.close()
        local path = vim.api.nvim_buf_get_name(0)
        -- silently ignore if file doesn't exist
        if path == "" or not vim.uv.fs_stat(path) then
          files.open(vim.fn.getcwd(), false)
          return
        end

        files.open(path, false)
        files.reveal_cwd()
      end, { desc = "Reveal current file" })
    end

    do
      -- hipatterns
      -- Match keyword labels followed by a colon or parenthesis, but not dotted access like vim.log.levels.WARN.
      local todo_suffix = "%s*[:%(]"

      local function todo_highlighter(keyword, group)
        return {
          pattern = {
            "^()" .. keyword .. "()" .. todo_suffix,
            "[^%.%w_]()" .. keyword .. "()" .. todo_suffix,
          },
          group = function(buf_id, _, data)
            for _, capture in ipairs(vim.treesitter.get_captures_at_pos(buf_id, data.line - 1, data.from_col - 1)) do
              if capture.capture:find("^comment") then
                return group
              end
            end
          end,
        }
      end

      local hipatterns = require("mini.hipatterns")

      hipatterns.setup({
        highlighters = {
          hex_color = hipatterns.gen_highlighter.hex_color(),

          bug = todo_highlighter("BUG", "MiniHipatternsFixme"),
          fix = todo_highlighter("FIX", "MiniHipatternsFixme"),
          fixit = todo_highlighter("FIXIT", "MiniHipatternsFixme"),
          fixme = todo_highlighter("FIXME", "MiniHipatternsFixme"),
          hack = todo_highlighter("HACK", "MiniHipatternsHack"),
          info = todo_highlighter("INFO", "MiniHipatternsNote"),
          issue = todo_highlighter("ISSUE", "MiniHipatternsFixme"),
          note = todo_highlighter("NOTE", "MiniHipatternsNote"),
          optimize = todo_highlighter("OPTIMIZE", "MiniHipatternsPerf"),
          optim = todo_highlighter("OPTIM", "MiniHipatternsPerf"),
          passed = todo_highlighter("PASSED", "MiniHipatternsTest"),
          perf = todo_highlighter("PERF", "MiniHipatternsPerf"),
          performance = todo_highlighter("PERFORMANCE", "MiniHipatternsPerf"),
          test = todo_highlighter("TEST", "MiniHipatternsTest"),
          testing = todo_highlighter("TESTING", "MiniHipatternsTest"),
          todo = todo_highlighter("TODO", "MiniHipatternsTodo"),
          warn = todo_highlighter("WARN", "MiniHipatternsWarn"),
          warning = todo_highlighter("WARNING", "MiniHipatternsWarn"),
        },
      })
    end

    do
      -- map
      local map = require("mini.map")

      vim.api.nvim_create_autocmd("FileType", {
        pattern = excluded_filetypes,
        callback = function(event)
          vim.b[event.buf].minimap_disable = true

          if event.buf == vim.api.nvim_get_current_buf() then
            map.close()
          end
        end,
      })

      map.setup({
        integrations = {
          -- FIXME: `builtin_search` moves the source cursor and restores it via
          -- `winrestview()`, but cursor-relative float geometry stays stale until redraw,
          -- so DiagnosticChanged refreshes can send blink.cmp to the top-left corner.
          -- Wait for https://github.com/nvim-mini/mini.nvim/issues/2509
          -- map.gen_integration.builtin_search({ search = "MiniMapSearch" }),
          map.gen_integration.diagnostic({
            error = "MiniMapDiagnosticError",
            warn = "MiniMapDiagnosticWarn",
            info = "MiniMapDiagnosticInfo",
            hint = "MiniMapDiagnosticHint",
          }),
          map.gen_integration.diff({
            add = "MiniMapDiffAdd",
            change = "MiniMapDiffChange",
            delete = "MiniMapDiffDelete",
          }),
        },
        window = {
          zindex = 60,
        },
      })

      local gap = 20

      local function should_show_map()
        if vim.bo.buftype ~= "" or vim.api.nvim_buf_get_name(0) == "" or vim.b.minimap_disable then
          return false
        end

        local col = vim.api.nvim_win_get_cursor(0)[2]
        return vim.api.nvim_win_get_width(0) - col >= gap
      end

      local function update_map()
        if vim.api.nvim_win_get_config(0).relative ~= "" then
          return
        end

        local should_show = should_show_map()
        if vim.w.ray_minimap_visible == should_show then
          return
        end

        vim.w.ray_minimap_visible = should_show
        if should_show then
          map.open()
        else
          map.close()
        end
      end

      vim.api.nvim_create_autocmd({ "BufWinEnter", "CursorMoved", "CursorMovedI" }, {
        callback = update_map,
      })

      vim.keymap.set("n", "<leader>um", function()
        map.toggle()
      end, { desc = "Toggle minimap" })

      update_map()
    end

    do
      -- sessions
      local sessions = require("mini.sessions")

      local session_dir = vim.fn.stdpath("state") .. "/sessions"

      local function encode_path(path)
        return path:gsub("[\\/:]+", "%%")
      end

      local function decode_path(path)
        local decoded = path:gsub("%%", "/")

        if jit.os:find("Windows") then
          decoded = decoded:gsub("^(%w)/", "%1:/")
        end

        return decoded
      end

      local function current_session_name()
        return encode_path(vim.fn.getcwd()) .. ".vim"
      end

      local function session_path(name)
        return vim.fs.normalize(session_dir .. "/" .. name)
      end

      local function read_session(name)
        if vim.fn.filereadable(session_path(name)) == 1 then
          sessions.read(name)
        end
      end

      local function has_file_buffer()
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[bufnr].buftype == "" and vim.api.nvim_buf_get_name(bufnr) ~= "" then
            return true
          end
        end
        return false
      end

      local function save_session(verbose, require_file_buffer)
        if require_file_buffer and not has_file_buffer() then
          return
        end

        sessions.write(current_session_name(), { force = true, verbose = verbose })
      end

      local function list_sessions()
        local paths = vim.fn.glob(session_dir .. "/*.vim", true, true)

        table.sort(paths, function(a, b)
          return vim.fn.getftime(a) > vim.fn.getftime(b)
        end)

        return vim.tbl_map(function(path)
          local name = vim.fn.fnamemodify(path, ":t")
          return { dir = decode_path(vim.fn.fnamemodify(name, ":r")), name = name }
        end, paths)
      end

      local function select_session()
        vim.ui.select(list_sessions(), {
          prompt = "Select a session: ",
          format_item = function(item)
            return vim.fn.fnamemodify(item.dir, ":p:~")
          end,
        }, function(item)
          if not item then
            return
          end

          save_session(false, true)
          vim.fn.chdir(item.dir)
          read_session(item.name)
        end)
      end

      local function load_last_session()
        local latest = list_sessions()[1]

        if latest then
          read_session(latest.name)
        end
      end

      sessions.setup({
        autoread = false,
        autowrite = false,
        directory = session_dir,
        file = "",
        force = {
          delete = false,
          read = false,
          write = true,
        },
        verbose = {
          delete = true,
          read = false,
          write = true,
        },
      })

      vim.api.nvim_create_autocmd("DirChanged", {
        callback = function()
          if vim.v.this_session ~= "" then
            vim.v.this_session = session_path(current_session_name())
          end
        end,
      })

      vim.api.nvim_create_autocmd("ExitPre", {
        callback = function()
          save_session(false, true)
        end,
      })

      vim.keymap.set("n", "<leader>pr", function()
        read_session(current_session_name())
      end, { desc = "Restore project session" })
      vim.keymap.set("n", "<leader>pw", function()
        save_session(true, false)
      end, { desc = "Save session" })
      vim.keymap.set("n", "<leader>ps", select_session, { desc = "Select session" })
      vim.keymap.set("n", "<leader>pl", load_last_session, { desc = "Restore last session" })
    end

    do
      -- snippets
      -- Keep MiniSnippets: nested sessions are required so snippets can expand inside active snippets.
      -- TODO: could be replaced by native vim.snippet after upgrading to nvim 0.13
      -- (that's why I move from mini.snippets -> vim.snippet and then back to mini.snippets btw)

      local snippets = require("mini.snippets")
      local gen_loader = snippets.gen_loader

      snippets.setup({
        snippets = {
          gen_loader.from_lang({
            lang_patterns = {
              javascriptreact = { "**/javascript.json" },
              typescript = { "**/javascript.json" },
              typescriptreact = { "**/javascript.json" },
              vue = { "**/vue.json", "**/javascript.json" },
            },
          }),
        },
        mappings = {
          expand = "",
          jump_next = "",
          jump_prev = "",
        },
        expand = {
          insert = function(snippet)
            return snippets.default_insert(snippet, {
              empty_tabstop = "",
              empty_tabstop_final = "",
            })
          end,
        },
      })

      vim.api.nvim_create_autocmd("ModeChanged", {
        pattern = "*:n",
        callback = function()
          while snippets.session.get() do
            snippets.session.stop()
          end
        end,
      })
    end

    do
      -- statusline
      local trunc_width = 120
      local max_path_width = 100

      local function statusline_escape(text)
        return tostring(text):gsub("%%", "%%%%")
      end

      local function statusline_macro()
        local register = vim.fn.reg_recording()

        if register == "" then
          return ""
        end

        return statusline_escape("recording @" .. register)
      end

      local function statusline_workspace()
        local workspace = vim.fn.fnamemodify(vim.fn.getcwd(0), ":t")

        if workspace == "" then
          return ""
        end

        return statusline_escape(workspace:upper())
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

        if vim.fn.strdisplaywidth(relative) <= max_path_width then
          return relative
        end

        local parts = vim.split(relative, "/", { plain = true })

        if #parts <= 2 then
          return relative
        end

        for tail_start = 3, #parts do
          local shortened = { parts[1], "…" }

          for index = tail_start, #parts do
            table.insert(shortened, parts[index])
          end

          relative = table.concat(shortened, "/")

          if vim.fn.strdisplaywidth(relative) <= max_path_width then
            break
          end
        end

        return relative
      end

      local function statusline_show_fileinfo()
        return not MiniStatusline.is_truncated(trunc_width) and vim.bo.buftype == ""
      end

      local function redraw_statusline()
        vim.schedule(function()
          vim.cmd.redrawstatus()
        end)
      end

      local function statusline_metadata()
        if not statusline_show_fileinfo() then
          return ""
        end

        local encoding = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding
        local format = vim.bo.fileformat

        return string.format("%s[%s]", encoding, format)
      end

      local function statusline_highlight(hl, text)
        return "%#" .. hl .. "#" .. statusline_escape(text)
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

      local function statusline_diagnostic_counts()
        if MiniStatusline.is_truncated(90) then
          return ""
        end

        local counts = vim.diagnostic.count(0)
        local diagnostic_config = require("ray.config.diagnostics")
        local severities = {
          { vim.diagnostic.severity.ERROR, "MiniStatuslineDiagnosticError" },
          { vim.diagnostic.severity.WARN, "MiniStatuslineDiagnosticWarn" },
          { vim.diagnostic.severity.INFO, "MiniStatuslineDiagnosticInfo" },
          { vim.diagnostic.severity.HINT, "MiniStatuslineDiagnosticHint" },
        }
        local parts = {}

        for _, item in ipairs(severities) do
          local severity, group = item[1], item[2]
          local count = counts[severity] or 0

          if count > 0 then
            table.insert(parts, statusline_highlight(group, diagnostic_config.sign(severity) .. " " .. count))
          end
        end

        if #parts == 0 then
          return ""
        end

        return table.concat(parts, " ") .. "%#MiniStatuslineDiagnostics#"
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

        local pretty_path = statusline_pretty_path()
        local directory, filename = pretty_path:match("^(.*[/\\])([^/\\]+)$")
        local path_part = "%#MiniStatuslineFilename#" .. statusline_escape(filename or pretty_path)

        if filename then
          path_part = "%#MiniStatuslineDirectory#"
            .. statusline_escape(directory)
            .. "%#MiniStatuslineFilename#"
            .. statusline_escape(filename)
        end

        return icon_part .. "%#MiniStatuslinePath# " .. path_part
      end

      local function statusline_active()
        local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = trunc_width })
        local workspace = statusline_workspace()
        local git = MiniStatusline.section_git({ trunc_width = trunc_width })
        local diff = statusline_diff()
        local file = statusline_file()
        local diagnostics = statusline_diagnostic_counts()
        local metadata = statusline_metadata()

        return MiniStatusline.combine_groups({
          { hl = mode_hl, strings = { mode } },
          { hl = "MiniStatuslineWorkspace", strings = { workspace } },
          { hl = "MiniStatuslineDevinfo", strings = { git, diff } },
          "%<",
          { hl = "MiniStatuslinePath", strings = { file } },
          { hl = "MiniStatuslineDiagnostics", strings = { diagnostics } },
          "%=",
          { hl = "MiniStatuslineInputState", strings = { statusline_macro(), "%S" } },
          { hl = "MiniStatuslineMetadata", strings = { statusline_escape(metadata) } },
          { hl = mode_hl, strings = { "%l/%L:%v" } },
        })
      end

      local function statusline_inactive()
        return "%#MiniStatuslineInactive#%="
      end

      require("mini.statusline").setup({
        content = {
          active = statusline_active,
          inactive = statusline_inactive,
        },
      })

      vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave", "DiagnosticChanged" }, {
        callback = redraw_statusline,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = { "MiniDiffUpdated", "MiniGitUpdated" },
        callback = redraw_statusline,
      })
    end

    do
      -- tabline
      local tabline = require("mini.tabline")

      tabline.setup({
        format = function(buf_id, label)
          local suffix = vim.bo[buf_id].modified and "[+] " or ""

          return " " .. tabline.default_format(buf_id, label) .. suffix .. " "
        end,
        tabpage_section = "right",
      })
    end
  end,
}
