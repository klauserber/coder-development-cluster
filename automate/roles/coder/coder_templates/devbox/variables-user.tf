
variable "restic_password_suffix" {
  type      = string
  default   = "default"
  description = <<-EOF
  Password to encrypt the backups. You provide the suffix of the password and we hold the prefix.
  EOF
}
