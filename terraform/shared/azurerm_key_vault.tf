resource "azurerm_key_vault" "base_security" {
  name                        = var.key_vault_kubernetes
  location                    = data.azurerm_resource_group.common.location
  resource_group_name         = data.azurerm_resource_group.common.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled    = false
  enabled_for_template_deployment = true
  enabled_for_deployment      = true

  sku_name = "standard"

  tags = merge(var.mandatory_tags,var.optional_tags)

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "List",
      "Delete",
      "Create",
      "Update",
      "Import",
      "Backup",
      "Recover",
      "Restore"
    ]

    secret_permissions = [
      "Get",
      "List",
      "Delete",
      "Set",
      "Backup",
      "Recover",
      "Restore"
    ]

    certificate_permissions = [
      "Get",
      "List",
      "Update",
      "Create",
      "Import",
      "Delete",
      "Backup",
      "Recover",
      "Restore"
    ]

    storage_permissions = [
      "Get",
    ]
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

# Creating the Key by referencing the SSH private key
resource "azurerm_key_vault_secret" "confluent_ssh_key" {
  name         = "ssh-private-key"
  value        = base64encode(tls_private_key.ssh_private_key.private_key_pem)
  key_vault_id = azurerm_key_vault.base_security.id
}

data "azurerm_client_config" "current" {}