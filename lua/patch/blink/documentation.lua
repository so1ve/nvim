local M = {}

local function has_text(value)
  if type(value) ~= "string" then
    return false
  end

  return value:find("%S") ~= nil
end

local function has_documentation(documentation)
  if type(documentation) == "string" then
    return has_text(documentation)
  end

  if type(documentation) ~= "table" then
    return false
  end

  if type(documentation.draw) == "function" then
    return true
  end

  return has_text(documentation.value)
end

local function buffer_has_content(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if has_text(line) then
      return true
    end
  end

  return false
end

function M.patch()
  local docs = require("blink.cmp.completion.windows.documentation")

  if docs._ray_empty_docs_patched then
    return
  end

  docs._ray_empty_docs_patched = true

  local config = require("blink.cmp.config").completion.documentation
  local sources = require("blink.cmp.sources.lib")
  local menu = require("blink.cmp.completion.windows.menu")

  function docs.show_item(context, item)
    docs.auto_show_timer:stop()
    if item == nil or not menu.win:is_open() then
      return docs.win:close()
    end

    sources
      .resolve(context, item)
      :map(function(resolved)
        local has_detail = has_text(resolved.detail)
        local has_docs = has_documentation(resolved.documentation)

        if not has_detail and not has_docs then
          docs.close()

          return
        end

        if docs.shown_item ~= resolved then
          local docs_buf = docs.win:get_buf()
          local default_render_opts = {
            bufnr = docs_buf,
            detail = resolved.detail,
            documentation = resolved.documentation,
            max_width = docs.win.config.max_width,
            use_treesitter_highlighting = config and config.treesitter_highlighting,
          }
          local default_impl = function(opts)
            require("blink.cmp.lib.window.docs").render_detail_and_documentation(
              vim.tbl_extend("force", default_render_opts, opts or {})
            )
          end

          local draw = type(resolved.documentation) == "table" and resolved.documentation.draw or config.draw
          vim.api.nvim_set_option_value("modifiable", true, { buf = docs_buf })
          draw({
            item = resolved,
            window = docs.win,
            config = config,
            default_implementation = default_impl,
          })
          vim.api.nvim_set_option_value("modifiable", false, { buf = docs_buf })

          if not buffer_has_content(docs_buf) then
            docs.close()

            return
          end
        end

        docs.shown_item = resolved

        if menu.win:get_win() then
          docs.win:open()
          docs.win:set_cursor({ 1, 0 })
          docs.update_position()
        end
      end)
      :catch(function(err)
        vim.notify(err, vim.log.levels.ERROR, { title = "blink.cmp" })
      end)
  end
end

return M
