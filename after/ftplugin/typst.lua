vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 2
vim.opt_local.formatoptions:remove("r")
vim.opt_local.formatoptions:append("o")

require("ray.utils.keymaps").map_display_line_motion()
