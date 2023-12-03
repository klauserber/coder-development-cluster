
data "coder_parameter" "sts" {
  count        = var.desktop_setup ? 1 : 0
  name         = "spring_tool_suite"
  type         = "bool"
  default      = false
  display_name = "Spring Tool Suite"
  mutable      = true
  # icon         = "/icon/google.svg"
}

# https://spring.io/tools
resource "coder_script" "sts" {
  count = var.desktop_setup && try(data.coder_parameter.sts.0.value, false) ? 1 : 0
  agent_id = coder_agent.devbox.id
  run_on_start = true
  display_name = "Spring Tool Suite"
  # icon = "/icon/google.svg"
  script = <<-EOF
  #!/bin/bash
  set -e
  if [[ ! -d ~/apps/sts ]]; then
    echo "Setup Spring Tool Suite"
    mkdir -p ~/apps
    cd /tmp
    echo "Downloading Spring Tool Suite"
    wget -qO spring-tool-suite.tar.gz https://cdn.spring.io/spring-tools/release/STS4/4.20.1.RELEASE/dist/e4.29/spring-tool-suite-4-4.20.1.RELEASE-e4.29.0-linux.gtk.x86_64.tar.gz
    echo "Extracting Spring Tool Suite"
    tar xzf spring-tool-suite.tar.gz 2> /dev/null
    mv sts-4.20.1.RELEASE ~/apps/sts
    rm spring-tool-suite.tar.gz

    echo "Create desktop launcher for Spring Tool Suite"
    echo "[Desktop Entry]
    Comment[en_US]=
    Comment=
    Exec=~/apps/sts/SpringToolSuite4
    GenericName[en_US]=
    GenericName=
    Icon=/home/coder/apps/sts/icon.xpm
    MimeType=
    Name[en_US]=Spring Tool Suite
    Name=Spring Tool Suite
    Path=
    StartupNotify=true
    Terminal=false
    TerminalOptions=
    Type=Application
    X-KDE-SubstituteUID=false
    X-KDE-Username=" > ~/Desktop/sts.desktop
  else
    echo "Spring Tool Suite is already installed"
  fi

  EOF
}

resource "coder_script" "sts_uninstall" {
  count = var.desktop_setup && try(data.coder_parameter.sts.0.value, false) ? 0 : 1
  agent_id = coder_agent.devbox.id
  run_on_start = true
  display_name = "Spring Tool Suite"
  # icon = "/icon/google.svg"
  script = <<-EOF
  #!/bin/bash
  set -e
  if [[ -d ~/apps/sts ]]; then
    echo "Uninstall Spring Tool Suite"
    rm -rf ~/apps/sts
    rm -f ~/Desktop/sts.desktop
  fi
  EOF
}