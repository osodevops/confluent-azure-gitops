resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "test" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name = "${var.cluster_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
  location = var.location
  resource_group_name = data.azurerm_resource_group.k8s.name
  sku = var.log_analytics_workspace_sku
  tags = merge(var.mandatory_tags,var.optional_tags)
}

resource "azurerm_log_analytics_solution" "test" {
  solution_name = "ContainerInsights"
  location = azurerm_log_analytics_workspace.test.location
  resource_group_name = data.azurerm_resource_group.k8s.name
  workspace_resource_id = azurerm_log_analytics_workspace.test.id
  workspace_name = azurerm_log_analytics_workspace.test.name
  tags = merge(var.mandatory_tags,var.optional_tags)
  plan {
    publisher = "Microsoft"
    product = "OMSGallery/ContainerInsights"
  }
}
