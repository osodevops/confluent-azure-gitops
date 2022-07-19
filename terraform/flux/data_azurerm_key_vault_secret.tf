data "azurerm_key_vault" "vault" {
  name                = var.key_vault_kubernetes
  resource_group_name = var.aks_resource_group
}

data "azurerm_key_vault_secret" "confluent_ssh_key" {
  name         = var.ssh_private_key
  key_vault_id = data.azurerm_key_vault.vault.id
}