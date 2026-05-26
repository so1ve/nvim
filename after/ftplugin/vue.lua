vim.opt_local.formatoptions:append("ro")

-- Vue's bundled ftplugin only declares HTML comments. Include C-style comments so
-- JSDoc blocks inside <script> keep Vim's native star continuation behavior.
vim.bo.comments = table.concat({
  "sO:* -",
  "mO:*  ",
  "exO:*/",
  "s1:/*",
  "mb:*",
  "ex:*/",
  "://",
  "s:<!--",
  "m:    ",
  "e:-->",
}, ",")
