aks_resource_group = "storage-resource-group"
location = "westeurope"

key_vault_kubernetes = "confluent-example-kv-01"

ssh_public_key = "confluent-example-sshpubkey-01"

ssh_private_key = "confluent-example-kafka-prod"


mandatory_tags = {
    "Environment" = "Production"
}

optional_tags = {
  "Environment" = "Production"
}