# Azure - HPCC AKS Root Module
<br />

# ** DO NOT USE IN PRODUCTION **
<br />
<br />


## Introduction

This module will deploy an HPCC AKS cluster using other abstracted modules.
<br />

<!--- BEGIN_TF_DOCS --->
## Providers

| Name | Version |
|------|---------|
| azurerm | >= 2.57.0 |
| random | ~>3.1.0 |
| kubernetes | ~>2.2.0 |
<br />

## Inputs
<br />

### Glossary
|||
|:--------:|------|
| Required | Cannot be commented out, but can be set to "" or null.|
|-| No default value |
<br />

### Admin
This block contains information on the user who is deploying the cluster. This is used as tags and part of some resources’ names to identify who deployed a given resource and how to contact that user. This block is required.

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| name | Name of the admin. | string | - | yes |
| email | Email address for the admin. | string | - | yes |

<br />

### Disable Naming Conventions
When set to true, this attribute drops the naming conventions set forth by the python module. This block is optional.

 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| disable_naming_conventions | Disable naming conventions. | bool | false | no |
<br />

### Metadata
TThe arguments in this block are used as tags and part of resources’ names. This block can be omitted when disable_naming_conventions is set to true.

 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| project_name | Name of the project. | string | "" | yes |
| product_name | Name of the product. | string | hpcc | no |
| business_unit | Name of your bussiness unit. | string | "" | no |
| environment | Name of the environment. | string | "" | no |
| market | Name of market. | string | "" | no |
| product_group | Name of product group. | string | "" | no |
| resource_group_type | Resource group type. | string | "" | no |
| sre_team | Name of SRE team. | string | "" | no |
| subscription_type | Subscription type. | string | "" | no |
<br />

### Tags
The tag attribute can be used for additional tags. The tags must be key value pairs. This block is optional.

 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| tags | Additional resource tags. | map(string) | admin | no |
<br />

### Resource Group
This block creates a resource group (like a folder) for your resources. This block is required.

 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| unique_name | Will concatenate a number at the end of your resource group name. | bool | true | yes |
| location | Cloud region in which to deploy the cluster resources. | string | null | yes |
<br />

### Gracefully Shut Kubernetes Cluster Down (without the storage).
This block solely shuts the Kubernetes cluster down. This block is optional.

 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| disable_kubernetes | Shut Kubernetes cluster down. `terraform apply -var-file=admin.tfvars` is needed afterwards. | bool | false | no |
<br />

### System Node Pool
This block creates a system node pool. This block is required.

 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| vm_size | Size of VM to use. | string | Standard_D2s_v3 | yes |
| node_count | Number of nodes to use. | number | 1 | yes |
<br />

### Additional Node Pool
This block creates additional node pools. This block is optional. 

 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| vm_size | Size of VM to use. | string | Standard_D2s_v3 | yes |
| enable_auto_scalling | Enable auto-scalling | bool | true | yes |
| min_count | Minimum number of nodes to use | number | 0 | yes |
| max_count | Maximum number of nodes to use. | number | 0 | yes |
<br />

### Image Root
This block contains information about the HPCC image to use. This block is optional.

 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| image_root | Image root to use. | string | hpccsystems | no |
<br />

### Image Name
This block contains information about the HPCC image to use. This block is optional.

 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| image_name | Image name to use. | string | platform-core | mo |
<br />

### Disable Helm Deployments
This block disable helm deployments by Terraform. This block is optional and will stop HPCC from being installed.

 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| disable_helm | Disable Helm deployments by Terraform. | bool | false | no |
<br />


### HPCC 
This block deploys the HPCC helm chart. This block is optional.

 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| chart | Path to local chart directory name. Examples: ./HPCC-Platform, ./helm-chart. | string | null | yes |
| namespace | Namespace to use. | string | default | yes |
| name | Release name of the chart. | string | `myhpcck8s` | yes |
| values | List of desired state files to use similar to -f in CLI. | list(string) | `values-retained-azurefile.yaml` | yes |
| version | Version of the HPCC chart. | string | latest | yes |
<br />

### Storage
This block deploys the HPCC persistent volumes. This block is optional.

 Name | Description | Type | Default | Valid Options | Required |
|------|-------------|------|---------|--------------|:-----:|
| access_tier | Defines the access tier for `BlobStorage`, `FileStorage`, `Storage2` accounts. | string | Hot | `Cool`, `Hot` | yes |
| account_kind | Defines the Kind of account. Changing this will destroy your data. | string | `StorageV2` | `BlobStorage`. `BlockBlobStorage`, `FileStorage`, `Storage`, `StorageV2` | yes |
| account_tier | Defines the Tier to use for this storage account. Changing this will destroy your data. | string | `Premium` | `Standard`, `Premium` | yes |
| disable_storage_account | Stop Terraform from creating a storage account. Persistent volumes will still be created. | bool | false | false, true | yes |
| enable_large_file_share | Enable Large File Share. | bool | false | `false`, `true` | yes |
| enable_static_website | Enable Static Website | bool | false | can only be set to `true` when the `account_kind` is set to `StorageV2` or `BlockBlobStorage` | yes |
| replication_type | Defines the type of replication to use for this storage account. Changing this will destroy your data. | string | `LRS` | `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS`, `RAGZRS` | yes |
| values | List of desired state files to use similar to -f in CLI. | list(string) | [] | no |
<br />

### ELK
This block deploys the ELK chart. This block is optional.

 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| enable | Enable ELK | bool | true | yes |
| name | name | Release name of the chart. | string | myhpccelk | yes |
| values | List of desired state files to use similar to -f in CLI. | list(string) | - | yes |
<br />

### Enable NGINX for ECLWatch
This block enables NGINX ingress for the ECLWatch service.

 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| enable_nginx | Enable NGINX ingress for ECLWatch service. | bool | false | no |
<br />

### Auto Connect to Kubernetes Cluster
This block automatically connect your cluster to your local machine similarly to `az aks get-credentials`.

 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| auto_connect | Automatically connect to the Kubernetes cluster from the host machine by overwriting the current context. | bool | false | no |
<br />

## Abstracted Modules
These are the list of all the abstracted modules.

| Name | Description | URL | Required |
|------|-------------|-----|:----------:|
| subscription | Queries enabled azure subscription from host machine | https://github.com/Azure-Terraform/terraform-azurerm-subscription-data.git | yes |
| naming | Enforces naming conventions | - | yes |
| metadata | Provides metadata | https://github.com/Azure-Terraform/terraform-azurerm-metadata.git | yes |
| resource_group | Creates a resource group | https://github.com/Azure-Terraform/terraform-azurerm-resource-group.git | yes |
| virtual_network | Creates a virtual network | https://github.com/Azure-Terraform/terraform-azurerm-virtual-network.git | yes |
| cheapest_spot_region | Returns the region name with the cheapest instance based on a given size | https://github.com/gfortil/terraform-azurerm-cheapest-region.git | no |
| kubernetes | Creates an Azure Kubernetes Service Cluster | https://github.com/Azure-Terraform/terraform-azurerm-kubernetes.git | yes |
<br />

## Outputs

| Name | Description | 
|------|-------------|
| aks_login | Get access credentials for the managed Kubernetes cluster. |
| recommendations | A list of security and cost recommendations for this deployment. Your environment has to have been deployed for several hours before Azure provides recommendations. |
<br />

## Usage
<ol>
<li>Clone this repo.</li>
<li>Copy `examples/admin.tfvars` to `terraform-azurerm-hpcc-aks`.</li>
<li>Open `terraform-azurerm-hpcc-aks/admin.tfvars` file.</li>
<li>Set attributes to your preferred values.</li>
<li>Save `terraform-azurerm-hpcc-aks/admin.tfvars` file.</li>
<li>Run `git clone https://github.com/hpcc-systems/helm-chart.git` in `terraform-azurerm-hpcc-aks` directory. This step is only required before your first `terraform apply`.</li>
<li>Run `terraform init`. This step is only required before your first `terraform apply`.</li>
<li>Run `terraform apply -var-file=admin.tfvars` or `terraform apply -var-file=admin.tfvars -auto-approve`.</li>
<li>Type `yes` if you didn't pass the flag `-auto-approve`.</li>
<li>If `auto_connect = true` (in admin.tfvars), skip this step.</li>
<ol>
<li>Copy aks_login command.</li>
<li>Run aks_login in your command line.</li>
<li>Accept to overwrite your current context.</li>
</ol>
<li>List pods: `kubectl get pods`.</li>
<li>Get ECLWatch external IP: `kubectl get svc --field-selector metadata.name=eclwatch | awk 'NR==2 {print $4}'`.</li>
<li>Delete cluster: `terraform destroy -var-file=admin.tfvars` or `terraform destroy -var-file=admin.tfvars -auto-approve`.</li>
<li>Type: `yes` if flag `-auto-approve` was not set.</li>
</ol>