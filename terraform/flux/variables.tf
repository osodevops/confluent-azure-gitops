variable "remote-branch-watch" {
    description = "The branch of CFK kubernetes configuration to monitor for changes"
}

variable "git-repo-url" {
    description = "The remote git repo that flux monitors for changes"
}
variable "aks_resource_group" {
    type = string
}

variable "key_vault_kubernetes"{
  type = string
  description = "Key vault"
}

variable "ssh_public_key" {
  type = string
  description = "Public key to be added to kubernetes cluster"
}

variable "ssh_private_key" {
  type = string
  description = "Private key"
}

variable "tfstate_key" {
  type = string
}

variable "resource_group_name" {
  type = string
  description = "Resource group to store terraform state files"
}

variable "storage_account_name" {
  type = string
  description = "Storage account to store terraform state files"
}

variable "flux_cluster" {
  type = string
  description = "Selects the cluster manifests"
}