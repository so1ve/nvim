-- Use visual-line movement (gj/gk) in Noice hover windows
-- so wrapped lines behave naturally
vim.keymap.set("n", "j", "gj", { buffer = true, nowait = true, silent = true, desc = "Hover down visual line" })
vim.keymap.set("n", "k", "gk", { buffer = true, nowait = true, silent = true, desc = "Hover up visual line" })
