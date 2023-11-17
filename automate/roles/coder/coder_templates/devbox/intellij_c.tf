
data "coder_parameter" "intellij_c" {
  count        = var.desktop_setup ? 1 : 0
  name         = "intellij-c"
  type         = "bool"
  default      = false
  display_name = "Intellij Community"
  mutable      = true
  icon         = "/icon/intellij.svg"
}

# https://www.jetbrains.com/idea/download/#section=linux
resource "coder_script" "intellij_c" {
  count = var.desktop_setup && data.coder_parameter.intellij_c.0.value ? 1 : 0
  agent_id = coder_agent.devbox.id
  run_on_start = true
  display_name = "Intellij Community"
  icon = "/icon/intellij.svg"
  script = <<-EOF
  #!/bin/bash
  set -e
  if [[ ! -d ~/apps/intellij-c ]]; then
    echo "Setup Intellij Community"
    mkdir -p ~/apps
    mkdir -p /tmp/idea-c
    cd /tmp/idea-c
    echo "Downloading Intellij Community"
    wget -qO idea.tar.gz https://download.jetbrains.com/idea/ideaIC-2023.2.5.tar.gz
    echo "Extracting Intellij Community"
    tar xzf idea.tar.gz
    mv idea-* ~/apps/intellij-c; \
    rm -rf /tmp/idea-c

    echo "Create desktop launcher for Intellij Ultimate"
    echo "[Desktop Entry]
    Comment[en_US]=
    Comment=
    Exec=~/apps/intellij-c/bin/idea.sh
    GenericName[en_US]=
    GenericName=
    Icon=/home/coder/apps/intellij-c/bin/idea.svg
    MimeType=
    Name[en_US]=IntelliJ Community
    Name=IDEA IntelliJ Community
    Path=
    StartupNotify=true
    Terminal=false
    TerminalOptions=
    Type=Application
    X-KDE-SubstituteUID=false
    X-KDE-Username=" > ~/Desktop/intellij-c.desktop
  else
    echo "Intellij Community is already installed"
  fi

  EOF
}

resource "coder_script" "intellij_c_uninstall" {
  count = var.desktop_setup && data.coder_parameter.intellij_c.0.value ? 0 : 1
  agent_id = coder_agent.devbox.id
  run_on_start = true
  display_name = "Intellij Community Uninstall"
  icon = "/icon/intellij.svg"
  script = <<-EOF
  #!/bin/bash
  set -e
  if [[ -d ~/apps/intellij-c ]]; then
    echo "Uninstall Intellij Community"
    rm -rf ~/apps/intellij-c
    rm -f ~/Desktop/intellij-c.desktop
  fi
  EOF
}