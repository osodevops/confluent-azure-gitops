cluster_name = "aks-confluent-prod"
location = "westeurope"

aks_resource_group = "storage-resource-group"
subnet_name = "subnet1"
virtual_network_name = "confluent"
networking_resource_group = "confluent"

mandatory_tags = {
    "Environment" = "Production"

}
optional_tags = {
  "Environment" = "Production"
}

pod_cidr = "172.24.64.0/20"
service_cidr = "10.240.16.0/24"
docker_bridge_cidr = "172.17.0.1/16"
dns_service_ip = "10.240.16.10"

ssh_public_key = "confluent-example-sshpubkey-01"