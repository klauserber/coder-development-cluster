
data "coder_parameter" "vscode_extension_spring" {
  name = "vscode_extensions_spring"
  display_name = "VS Code Extension Spring tools"
  type = "bool"
  default = false
  mutable = true
}
data "coder_parameter" "vscode_extension_k8s" {
  name = "vscode_extensions_k8s"
  display_name = "VS Code Extension Kubernetes"
  type = "bool"
  icon = "/icon/k8s.png"
  default = false
  mutable = true
}
data "coder_parameter" "vscode_extension_docker" {
  name = "vscode_extensions_docker"
  display_name = "VS Code Extension Docker"
  type = "bool"
  icon = "/icon/docker.png"
  default = false
  mutable = true
}

module "code-server" {
  source          = "https://registry.coder.com/modules/code-server"
  agent_id        = coder_agent.devbox.id
  install_version = "4.20.0"
  extensions = setunion(
    toset( data.coder_parameter.vscode_extension_docker.value ? ["ms-azuretools.vscode-docker"] : []),
    toset( data.coder_parameter.vscode_extension_spring.value ? ["vmware.vscode-boot-dev-pack"] : []),
    toset( data.coder_parameter.vscode_extension_k8s.value ? ["ms-kubernetes-tools.vscode-kubernetes-tools"] : [])
  )
}

resource "coder_script" "vscode_desktop_extensions" {
  count = var.desktop_setup ? 1 : 0
  agent_id = coder_agent.devbox.id
  run_on_start = true
  display_name = "Install VS Code Desktop Extensions"
  icon = "/icon/code.svg"
  script = <<-EOF
  #!/bin/bash
  set -e
  if [[ "${data.coder_parameter.vscode_extension_spring.value}" == "true" ]]; then
    echo "Install VS Code Spring tools"
    code --force --install-extension vmware.vscode-boot-dev-pack 2> /dev/null
  fi
  if [[ "${data.coder_parameter.vscode_extension_k8s.value}" == "true" ]]; then
    echo "Install VS Code Kubernetes tools"
    code --force --install-extension ms-kubernetes-tools.vscode-kubernetes-tools 2> /dev/null
  fi
  if [[ "${data.coder_parameter.vscode_extension_docker.value}" == "true" ]]; then
    echo "Install VS Code Docker tools"
    code --force --install-extension ms-azuretools.vscode-docker 2> /dev/null
  fi
  EOF
}

