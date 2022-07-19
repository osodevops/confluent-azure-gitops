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
    known_hosts    = "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="
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