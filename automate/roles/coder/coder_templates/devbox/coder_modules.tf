
module "filebrowser" {
  source        = "https://registry.coder.com/modules/filebrowser"
  agent_id      = coder_agent.devbox.id
  folder        = "/home/coder"
  database_path = ".config/filebrowser.db"
}
