-- Orchestrates Noice monkey patches in dependency order.
-- Purpose: keep each patch focused on one concern while still applying them
-- before `require("noice").setup()` in the plugin spec.
-- Implementation: markdown link rendering is patched first because width/layout
-- patches consume its visual-width data. Layout then owns active hover state.
-- Noice's own hover scrollbar is disabled in plugin config.

local M = {}

function M.patch()
  require("patch.noice.markdown-links").patch()
  require("patch.noice.markdown-width").patch()
  require("patch.noice.hover-layout").patch()
end

return M
