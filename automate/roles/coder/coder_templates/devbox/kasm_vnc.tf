
resource "coder_app" "kasmvnc" {
  count        = var.desktop_setup ? 1 : 0
  agent_id     = coder_agent.devbox.id
  slug         = "desktop"
  display_name = "Desktop"
  url          = "http://localhost:6901"
  icon         = "/icon/kasmvnc.svg"
  subdomain    = true
  share        = "owner"
  healthcheck {
    url       = "http://localhost:6901"
    interval  = 5
    threshold = 6
  }
}

resource "coder_script" "desktop_setup" {
  count        = var.desktop_setup ? 1 : 0
  agent_id     = coder_agent.devbox.id
  run_on_start = true
  display_name = "kasm vnc setup"
  icon         = "/icon/kasmvnc.svg"
  script       = <<-EOF
  #!/bin/bash
  echo "Setup kasm vnc"
  run_kasmvnc.sh 2>&1
  EOF
}
