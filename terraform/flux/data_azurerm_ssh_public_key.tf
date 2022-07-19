data "azurerm_ssh_public_key" "confluent_public_key" {
  name                = var.ssh_public_key
  resource_group_name = var.aks_resource_group
}