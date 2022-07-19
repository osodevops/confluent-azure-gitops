# Bootstrap Flux v2
# Note: mamaged GitOps for AKS as addon is in preview - plan to switch when available via Terraform
data "flux_install" "main" {
  target_path    = "./cluster-manifests/clusters/${var.flux_cluster}"
  network_policy = false
  version        = "latest"
}

data "flux_sync" "confluent" {
  target_path = "./cluster-manifests/clusters/${var.flux_cluster}"
  url         = var.git-repo-url
  branch      = var.remote-branch-watch
  name        = "confluent"
}


# Create flux-system namespace
resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels
    ]
  }

}

resource "kubernetes_secret" "common" {
  depends_on = [kubectl_manifest.apply]

  metadata {
    name      = "flux-system"
    namespace = data.flux_sync.confluent.namespace
  }

  data = {
    identity       = base64decode(data.azurerm_key_vault_secret.confluent_ssh_key.value)
    "identity.pub" = data.azurerm_ssh_public_key.confluent_public_key.public_key
    known_hosts = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
  }
}

# Split multi-doc YAML with
# https://registry.terraform.io/providers/gavinbunney/kubectl/latest
data "kubectl_file_documents" "apply" {
  content = data.flux_install.main.content
}

# Convert documents list to include parsed yaml data
locals {
  apply = [for v in data.kubectl_file_documents.apply.documents : {
    data : yamldecode(v)
    content : v
  }
  ]
}

# Apply manifests on the cluster
resource "kubectl_manifest" "apply" {
  for_each   = { for v in local.apply : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system]
  yaml_body  = each.value
}

##### SYNC COMMANDS > Split multi-doc YAML with
# https://registry.terraform.io/providers/gavinbunney/kubectl/latest
data "kubectl_file_documents" "sync-confluent" {
  content = data.flux_sync.confluent.content
}

# Convert documents list to include parsed yaml data
locals {
  sync-confluent = [for v in data.kubectl_file_documents.sync-confluent.documents : {
    data : yamldecode(v)
    content : v
  }
  ]
}

# Apply manifests on the cluster
resource "kubectl_manifest" "sync-confluent" {
  for_each   = { for v in local.sync-confluent : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [kubernetes_namespace.flux_system, kubectl_manifest.apply]
  yaml_body  = each.value
}