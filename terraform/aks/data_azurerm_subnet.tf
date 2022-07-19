data "azurerm_subnet" "private" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.networking_resource_group
}