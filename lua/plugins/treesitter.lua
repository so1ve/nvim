return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local CHECK_INTERVAL_MS = 500
    local TIMEOUT_MS = 120000
    local MAX_CHECKS = math.ceil(TIMEOUT_MS / CHECK_INTERVAL_MS)

    local treesitter = require("nvim-treesitter")
    local on_demand = require("utils.on-demand")
    local notify = require("utils.notify")
    local group = vim.api.nvim_create_augroup("RayTreesitter", { clear = true })
    local installing = {}
    local waiting_buffers = {}

    treesitter.setup()

    vim.treesitter.language.register("javascript", { "javascriptreact" })
    vim.treesitter.language.register("json", { "jsonc" })
    vim.treesitter.language.register("tsx", { "typescriptreact" })

    local function buffer_lang(bufnr)
      local filetype = vim.bo[bufnr].filetype
      return filetype ~= "" and vim.treesitter.language.get_lang(filetype) or nil
    end

    local function buffer_matches(bufnr, lang)
      return vim.api.nvim_buf_is_valid(bufnr)
        and vim.api.nvim_buf_is_loaded(bufnr)
        and buffer_lang(bufnr) == lang
    end

    local function parser_available(lang)
      return lang ~= nil and vim.list_contains(treesitter.get_available(), lang)
    end

    local function parser_loadable(lang)
      return vim.treesitter.language.add(lang) == true
    end

    local function queue_buffer(bufnr, lang)
      waiting_buffers[lang] = waiting_buffers[lang] or {}
      waiting_buffers[lang][bufnr] = true
    end

    local function for_waiting_buffer(lang, callback)
      local buffers = waiting_buffers[lang]
      if not buffers then
        return false
      end

      local has_buffer = false
      for bufnr in pairs(buffers) do
        if buffer_matches(bufnr, lang) then
          has_buffer = true
          if callback then
            callback(bufnr)
          end
        else
          buffers[bufnr] = nil
        end
      end

      if callback or not has_buffer then
        waiting_buffers[lang] = nil
      end

      return has_buffer
    end

    local function stop_timer(timer, lang)
      installing[lang] = nil
      timer:stop()
      timer:close()
    end

    local function watch_parser(lang)
      local checks = 0
      local timer = vim.uv.new_timer()
      if not timer then
        installing[lang] = nil
        return
      end

      timer:start(CHECK_INTERVAL_MS, CHECK_INTERVAL_MS, vim.schedule_wrap(function()
        checks = checks + 1

        if not for_waiting_buffer(lang) then
          stop_timer(timer, lang)
          return
        end

        if parser_loadable(lang) then
          stop_timer(timer, lang)
          notify("Parser installed: " .. lang, vim.log.levels.INFO, "Tree-sitter")
          for_waiting_buffer(lang, function(bufnr)
            vim.treesitter.start(bufnr, lang)
          end)
          return
        end

        if checks >= MAX_CHECKS then
          stop_timer(timer, lang)
          waiting_buffers[lang] = nil
          notify("Parser install timed out: " .. lang, vim.log.levels.WARN, "Tree-sitter")
        end
      end))
    end

    local function install_parser(lang)
      if installing[lang] then
        return
      end

      if vim.fn.executable("tree-sitter") ~= 1 then
        on_demand.ensure_package("tree-sitter-cli", {
          title = "Tree-sitter",
          on_ready = function()
            if vim.fn.executable("tree-sitter") == 1 then
              install_parser(lang)
            else
              notify("tree-sitter-cli installed but not available on PATH", vim.log.levels.ERROR, "Tree-sitter")
            end
          end,
        })
        return
      end

      installing[lang] = true
      notify("Installing parser: " .. lang, vim.log.levels.INFO, "Tree-sitter")
      treesitter.install({ lang })
      watch_parser(lang)
    end

    local function ensure_parser(bufnr)
      local lang = buffer_lang(bufnr)
      if not lang then
        return
      end

      on_demand.ensure_language(lang)

      if not parser_available(lang) then
        return
      end

      if parser_loadable(lang) then
        vim.treesitter.start(bufnr, lang)
        return
      end

      queue_buffer(bufnr, lang)
      install_parser(lang)
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      desc = "Install Tree-sitter parser on demand",
      callback = function(event)
        ensure_parser(event.buf)
      end,
    })

  end,
}
