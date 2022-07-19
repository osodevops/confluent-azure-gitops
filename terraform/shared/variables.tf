variable "aks_resource_group" {
  type = string
}

variable "location" {
  description = "Region where shared resources are deployed to"
}

variable "mandatory_tags" {
    type        = map(string)
    description = "Common set of tags to apply to all resources created by the modules"
    default     = {}
}
variable "optional_tags" {
    type = map(string)
    description = "Set of optional tags to apply to all resources created by the modules"
    default = {
    }
}

variable "key_vault_kubernetes"{
  type = string
  description = "Key vault"
}

variable "ssh_public_key" {
  type = string
  description = "Public key to be added to kubernetes cluster"
}

variable ssh_private_key {
  type = string
  description = "Private key"
}
