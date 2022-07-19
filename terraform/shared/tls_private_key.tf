resource "tls_private_key" "ssh_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}