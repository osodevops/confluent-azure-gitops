variable cluster_name {
    description = "unique identifier for cluster"
}

variable "agent_count" {
    default = 5
}
variable location {
    description = "Azure Region to deploy the cluster into"
}
# refer https://azure.microsoft.com/pricing/details/monitor/
# for log analytics pricing
variable log_analytics_workspace_sku {
    default = "PerGB2018"
}

variable "aks_resource_group" {
    type = string
}

variable "arm_client_id" {
    type = string
}

variable subnet_name {
    type = string
}

variable virtual_network_name {
    type = string
}

variable networking_resource_group {
    type = string
}

variable "arm_client_secret" {
    type = string
}

variable "mandatory_tags" {
    type        = map(string)
    description = "Common set of tags to apply to all resources created by the modules"
    default     = {}
}

variable "vm_sizing" {
    type = string
    description = "VM size for kubernetes worker nodes"
    default = "Standard_D3_v2"
}

variable "optional_tags" {
    type = map(string)
    description = "Set of optional tags to apply to all resources created by the modules"
    default = {
    }
}

variable "pod_cidr" {
    type = string
    description = "The CIDR to use for pod IP addresses"  
}

variable "dns_service_ip" {
    type = string
    description = "IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)"
}

variable "docker_bridge_cidr" {
    type = string
    description = "IP address (in CIDR notation) used as the Docker bridge IP address on nodes" 
}

variable "service_cidr" {
    type = string
    description = "The Network Range used by the Kubernetes service"
  
}

variable "ssh_public_key" {
    type = string
    description = "Public key to be added to the aks nodes"
}