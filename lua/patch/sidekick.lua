local hacks = require("utils.hacks")

local M = {}

function M.patch()
  if vim.fn.has("win32") == 0 then
    return
  end

  hacks.on_module("sidekick.cli.session", function(session)
    hacks.wrap(session, "sidekick_windows_zellij_session_names", "sid", function(original)
      return function(opts)
        local value = original(opts)

        -- Sidekick uses the session id in both zellij session names and layout
        -- file names. Spaces are split incorrectly by the Windows terminal job
        -- wrapper before zellij receives its arguments.
        return (value:gsub("%s+", "-"))
      end
    end)
  end)
end

return M
