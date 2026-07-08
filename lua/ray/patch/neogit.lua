local hacks = require("ray.patch.hacks")

local M = {}

local function is_windows()
  return vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
end

local function is_absolute_path(path)
  return path:match("^%a:[/\\]") ~= nil or path:sub(1, 1) == "/" or path:sub(1, 2) == "\\\\"
end

function M.patch()
  if not is_windows() then
    return
  end

  hacks.on_module("neogit.buffers.status.actions", function(actions)
    hacks.once(actions, "NeogitOrg/neogit#1984", function()
      local cleanup_items
      local index = 1

      while true do
        local name, value = debug.getupvalue(actions.n_discard, index)
        assert(name, "Neogit cleanup_items upvalue not found")

        if name == "cleanup_items" then
          cleanup_items = value
          break
        end

        index = index + 1
      end

      index = 1
      while true do
        local name, neogit_absolute_path = debug.getupvalue(cleanup_items, index)
        assert(name, "Neogit absolute_path upvalue not found")

        if name == "absolute_path" then
          local absolute_path_index = index

          debug.setupvalue(cleanup_items, absolute_path_index, function(path)
            if is_absolute_path(path) then
              return vim.fs.normalize(path)
            end

            return neogit_absolute_path(path)
          end)
          hacks.cleanup(function()
            debug.setupvalue(cleanup_items, absolute_path_index, neogit_absolute_path)
          end)
          return
        end

        index = index + 1
      end
    end)
  end)
end

return M
