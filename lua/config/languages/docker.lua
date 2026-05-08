return {
  languages = {
    dockerfile = {
      treesitter = "dockerfile",
      lsp = { "dockerls" },
      tools = { "hadolint" },
      linters = { "hadolint" },
    },
    ["yaml.docker-compose"] = {
      treesitter = "yaml",
      lsp = { "docker_compose_language_service" },
    },
  },
  servers = {
    docker_compose_language_service = {},
    dockerls = {},
  },
}
