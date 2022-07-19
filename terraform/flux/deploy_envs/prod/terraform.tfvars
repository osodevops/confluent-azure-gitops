cluster_name = "aks-confluent-prod"
location = "westeurope"
remote-branch-watch = "main"
tfstate_key= "kafka/prod/aks.terraform.tfstate"
git-repo-url = "ssh://git@github.com/osodevops/confluent-azure-gitops.git"

key_vault_kubernetes = "confluent-example-kv-01"
aks_resource_group = "storage-resource-group"
resource_group_name = "storage-resource-group"
storage_account_name = "confluentstorage"


ssh_public_key = "confluent-example-sshpubkey-01"

ssh_private_key = "confluent-example-kafka-prod"

flux_cluster = "prod"