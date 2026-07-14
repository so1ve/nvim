vim.g.filetype_typ = "typst"

vim.filetype.add({
  extension = {
    json5 = "jsonc",
  },
  filename = {
    ["compose.yaml"] = "yaml.docker-compose",
    ["compose.yml"] = "yaml.docker-compose",
    ["docker-compose.yaml"] = "yaml.docker-compose",
    ["docker-compose.yml"] = "yaml.docker-compose",
  },
  pattern = {
    [".*[\\/]%.github[\\/]workflows[\\/][^\\/]+%.ya?ml%..*"] = { "yaml", { priority = 1 } },
    [".*[\\/]%.github[\\/]workflows[\\/][^\\/]+%.ya?ml"] = "yaml.github-actions",
    ["compose%..*%.ya?ml"] = "yaml.docker-compose",
    ["docker%-compose%..*%.ya?ml"] = "yaml.docker-compose",
  },
})
