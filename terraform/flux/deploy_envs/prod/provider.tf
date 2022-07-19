# Providers
terraform {
    required_providers {
        flux = {
            source = "fluxcd/flux"
        }
        kubernetes = {
            source = "hashicorp/kubernetes"
        }
        kubectl = {
            source  = "gavinbunney/kubectl"
            version = "1.10.0"
        }
    }
}

provider "azurerm" {
    skip_provider_registration = true
    features {}
}


data "terraform_remote_state" "cluster" {
    backend = "azurerm"
    config = {
        storage_account_name  = "${var.storage_account_name}"
        resource_group_name  = "${var.resource_group_name}"
        container_name = "tfstate"
        key =  "${var.tfstate_key}"
    }
}

# Configure Flux v2 bootstrapper
provider "flux" {}

# Configure Kubernetes provider
provider "kubernetes" {
    host                   = data.terraform_remote_state.cluster.outputs.host
    client_certificate     = base64decode(data.terraform_remote_state.cluster.outputs.client_certificate)
    client_key             = base64decode(data.terraform_remote_state.cluster.outputs.client_key)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster.outputs.cluster_ca_certificate)
}

provider "kubectl" {
    host                   = data.terraform_remote_state.cluster.outputs.host
    client_certificate     = base64decode(data.terraform_remote_state.cluster.outputs.client_certificate)
    client_key             = base64decode(data.terraform_remote_state.cluster.outputs.client_key)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster.outputs.cluster_ca_certificate)
}