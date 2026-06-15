return {
  filetypes = {
    filename = {
      ["compose.yaml"] = "yaml.docker-compose",
      ["compose.yml"] = "yaml.docker-compose",
      ["docker-compose.yaml"] = "yaml.docker-compose",
      ["docker-compose.yml"] = "yaml.docker-compose",
    },
    pattern = {
      ["compose%..*%.ya?ml"] = "yaml.docker-compose",
      ["docker%-compose%..*%.ya?ml"] = "yaml.docker-compose",
    },
  },
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
}
