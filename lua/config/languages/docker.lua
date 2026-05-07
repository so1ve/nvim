return {
  languages = {
    dockerfile = {
      treesitter = "dockerfile",
      lsp = { "docker_language_server" },
    },
    ["yaml.docker-compose"] = {
      treesitter = "yaml",
      lsp = { "docker_language_server" },
    },
  },
  servers = {
    docker_language_server = {},
  },
}
