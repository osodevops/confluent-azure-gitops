//resource "azurerm_container_registry" "acr" {
//  name                     = replace(var.cluster_name, "-", "")
//  resource_group_name      = data.azurerm_resource_group.k8s.name
//  location                 = data.azurerm_resource_group.k8s.location
//  sku                      = "Premium"
//  admin_enabled            = true
//  public_network_access_enabled = true
//}
//
//resource "azurerm_role_assignment" "aks_sp_container_registry" {
//  scope                = azurerm_container_registry.acr.id
//  role_definition_name = "AcrPull"
//  principal_id         = azuread_service_principal.k8s.object_id
//}