-- FFF picker backdrop patch.
-- Purpose: dim the editor behind fff's floating picker, matching Snacks'
-- backdrop behavior without changing fff's upstream layout code.
-- Behavior: create one non-focusable editor-sized float below the picker windows;
-- resize it with the picker and always close it with the picker.

local M = {}
local Backdrop = require("ray.patch.backdrop")
local hacks = require("ray.patch.hacks")

local BACKDROP_ZINDEX = 50

local function create_backdrop()
  return Backdrop.new({
    filetype = "fff_backdrop",
    zindex = BACKDROP_ZINDEX,
  })
end

local function close_backdrop(picker)
  local state = picker.state

  if state.backdrop then
    state.backdrop:close()
  end
  state.backdrop = nil
end

local function open_backdrop(picker)
  local state = picker.state

  close_backdrop(picker)
  state.backdrop = create_backdrop()
  state.backdrop:open()
end

local function sync_backdrop(picker)
  local state = picker.state

  if not state.active then
    close_backdrop(picker)
    return
  end

  if state.backdrop then
    state.backdrop:sync()
    return
  end

  open_backdrop(picker)
end

function M.patch()
  hacks.on_module("fff.picker_ui.picker_ui", function(picker)
    hacks.wrap(picker, "fff.backdrop.create_ui", "create_ui", function(create_ui)
      return function(...)
        open_backdrop(picker)

        local result = create_ui(...)

        if not result then
          close_backdrop(picker)
        end

        return result
      end
    end)

    hacks.wrap(picker, "fff.backdrop.relayout", "relayout", function(relayout)
      return function(...)
        local result = relayout(...)
        sync_backdrop(picker)
        return result
      end
    end)

    hacks.wrap(picker, "fff.backdrop.close", "close", function(close)
      return function(...)
        local result = close(...)
        close_backdrop(picker)
        return result
      end
    end)
  end)
end

return M
