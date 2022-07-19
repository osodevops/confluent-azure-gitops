resource "azurerm_ssh_public_key" "ssh_public_key" {
  name                = var.ssh_public_key
  resource_group_name = upper(data.azurerm_resource_group.common.name)
  location            = var.location
  public_key          = tls_private_key.ssh_private_key.public_key_openssh

  lifecycle {
    ignore_changes = [tags]
  }

}