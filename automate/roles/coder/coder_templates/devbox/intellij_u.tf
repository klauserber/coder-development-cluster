
data "coder_parameter" "intellij_u" {
  count        = var.desktop_setup ? 1 : 0
  name         = "intellij-u"
  type         = "bool"
  default      = false
  display_name = "Intellij Ultimate (license needed)"
  mutable      = true
  icon         = "/icon/intellij.svg"
}

# https://www.jetbrains.com/idea/download/#section=linux
resource "coder_script" "intellij_u" {
  count = var.desktop_setup && data.coder_parameter.intellij_u.0.value ? 1 : 0
  agent_id = coder_agent.devbox.id
  run_on_start = true
  display_name = "Intellij Ultimate"
  icon = "/icon/intellij.svg"
  script = <<-EOF
  #!/bin/bash
  set -e
  if [[ ! -d ~/apps/intellij-u ]]; then
    echo "Setup Intellij Ultimate"
    mkdir -p ~/apps
    mkdir -p /tmp/idea-u
    cd /tmp/idea-u
    echo "Downloading Intellij Ultimate"
    wget -qO idea.tar.gz https://download.jetbrains.com/idea/ideaIU-2023.2.4.tar.gz
    echo "Extracting Intellij Ultimate"
    tar xzf idea.tar.gz
    mv idea-* ~/apps/intellij-u; \
    rm -rf /tmp/idea-u

    echo "Create desktop launcher for Intellij Ultimate"
    echo "[Desktop Entry]
    Comment[en_US]=
    Comment=
    Exec=~/apps/intellij-u/bin/idea.sh
    GenericName[en_US]=
    GenericName=
    Icon=/home/coder/apps/intellij-u/bin/idea.svg
    MimeType=
    Name[en_US]=IntelliJ Ultimate
    Name=IDEA IntelliJ Ultimate
    Path=
    StartupNotify=true
    Terminal=false
    TerminalOptions=
    Type=Application
    X-KDE-SubstituteUID=false
    X-KDE-Username=" > ~/Desktop/intellij-u.desktop
  else
    echo "Intellij Ultimate is already installed"
  fi

  EOF
}

resource "coder_script" "intellij_u_uninstall" {
  count = var.desktop_setup && data.coder_parameter.intellij_u.0.value ? 0 : 1
  agent_id = coder_agent.devbox.id
  run_on_start = true
  display_name = "Intellij Ultimate Uninstall"
  icon = "/icon/intellij.svg"
  script = <<-EOF
  #!/bin/bash
  set -e
  if [[ -d ~/apps/intellij-u ]]; then
    echo "Uninstall Intellij Ultimate"
    rm -rf ~/apps/intellij-u
    rm -f ~/Desktop/intellij-u.desktop
  fi
  EOF
}