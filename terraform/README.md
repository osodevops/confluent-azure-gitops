# Confluent Azure Terraform Setup Guide 

Terraform definition for AKS cluster setup.

The definition is primarily based on Microsoft reference:
https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks

HashiCorp has a bit slimmer tutorial:
https://learn.hashicorp.com/tutorials/terraform/aks

## Kubernetes cluster provisioning steps

. Get Azure CLI from Microsoft https://docs.microsoft.com/en-gb/cli/azure/

. Get Kubernetes CLI https://kubernetes.io/docs/tasks/tools/

. Login to Azure:

```
az login
```

. Create service principal
https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli

```
az ad sp create-for-rbac --name confluent
```

Keep `appId`, `password` and `tenant` values.
Confluent Operator will act as this principal interacting with AKS.

. Setup Azure storage

https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks#set-up-azure-storage-to-store-terraform-state

```shell
# using the cli
az group create \
  --name storage-resource-group \
  --location ukwest
  
az storage account create \
  --name confluentstorage \
  --resource-group storage-resource-group \
  --location ukwest \
  --sku Standard_RAGRS \
  --kind StorageV2
  
az storage container create \
  --name tfstate \
  --account-name confluentstorage

```
Keep the storage account name: `storage-resource-group`

### Deploy Shared Components

The Terraform definition uses this storage to keep the shared deployment state as opposite to the single user local deployment.
Keep the storage name and its access key.

. Initialize Terraform with the created storage

```
cd shared && 
DEPLOY_ENV=prod make apply 
```

### Deploy vnet 
. Export the service principal credentials and prepare the deployment plan

```
cd vnet &&
DEPLOY_ENV=prod make apply

```

### Deploy the AKS cluster
. Execute the deployment

```
export TF_VAR_arm_client_id=<service-principal-appid>
export TF_VAR_arm_client_secret=<service-principal-password>

cd aks &&
DEPLOY_ENV=prod make apply
```

. Obtain the config for accessing the cluster

```
terraform output -raw kube_config > ~/.azurek8s
```

. Set the config as the default one

```
export KUBECONFIG=~/.azurek8s
```

. Verify the kubernetes cluster works

```
kubectl get nodes
NAME                                STATUS   ROLES   AGE   VERSION
aks-agentpool-16523052-vmss000000   Ready    agent   24h   v1.18.14
aks-agentpool-16523052-vmss000001   Ready    agent   24h   v1.18.14
aks-agentpool-16523052-vmss000002   Ready    agent   24h   v1.18.14
aks-agentpool-16523052-vmss000003   Ready    agent   24h   v1.18.14
aks-agentpool-16523052-vmss000004   Ready    agent   24h   v1.18.14
aks-agentpool-16523052-vmss000005   Ready    agent   24h   v1.18.14
```

