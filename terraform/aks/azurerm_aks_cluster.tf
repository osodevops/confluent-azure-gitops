resource "azurerm_kubernetes_cluster" "k8s" {
  name = var.cluster_name
  location = var.location
  resource_group_name = data.azurerm_resource_group.k8s.name
  node_resource_group = "${data.azurerm_resource_group.k8s.name}-aks-nodes"
  dns_prefix = var.cluster_name

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = data.azurerm_ssh_public_key.confluent_public_key.public_key
    }
  }

  # private cluster settings
  private_cluster_enabled = false

  default_node_pool {
    name = "agentpool"
    vnet_subnet_id = data.azurerm_subnet.private.id
    vm_size = "Standard_D2s_v3"
    enable_auto_scaling = true
    max_count = 3
    min_count = 3
    enable_node_public_ip = false
  }

  service_principal {
    client_id = var.arm_client_id
    client_secret = var.arm_client_secret
  }
  
#  role_based_access_control {
#    enabled = false
#  }
#  addon_profile {
#
#    aci_connector_linux {
#      enabled     = false
#    }
#
#    oms_agent {
#      enabled = true
#      log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
#    }
#
#    azure_policy {
#      enabled = true
#    }
#
#    kube_dashboard {
#      enabled = false
#    }
#
#    azure_keyvault_secrets_provider {
#      enabled = false
#    }
#  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin = "azure"
    network_mode   = "transparent"
    network_policy = "azure"
  }

  tags = merge(var.mandatory_tags,var.optional_tags)
}



