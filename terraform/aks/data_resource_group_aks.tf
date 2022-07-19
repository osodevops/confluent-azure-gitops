data "azurerm_resource_group" "k8s" {
  name = var.aks_resource_group
}