
variable "restic_password_suffix" {
  type      = string
  default   = "default"
  description = <<-EOF
  We are making backups of your home directory. This is your part of the password that will be used to encrypt the backups.
  Do not forget it, nobody will be able to restore the data without it. If you leave it empty, your part of the password will be 'default'.
  The data will be encrypted with the password '<our part of the password>-default'.
  That means nobody except you and us will be able to restore the data.
  EOF
}
