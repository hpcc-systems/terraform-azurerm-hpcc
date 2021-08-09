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
| - | Conditional. |
<br />

### Admin
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| name | Name of the admin. | string | - | yes |
| email | Email address for the admin. | string | - | yes |

<br />

### Metadata
The following inputs are enforced when naming_conventions_enabled is true. See Naming module for acceptable input values. <br />
Setting any of the input variables to null will use their default values. See the variables.tf file for default values. <br />

 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| project_name | Name of the project. | string | - | yes |
| product_name | Name of the product. | string | hpcc | no |
| business_unit | Name of your bussiness unit. | string | - | no |
| environment | Name of the environment. | string | - | no |
| market | Name of market. | string | - | no |
| product_group | Name of product group. | string | - | no |
| resource_group_type | Resource group type. | string | - | no |
| sre_team | Name of SRE team. | string | - | no |
| subscription_type | Subscription type. | string | - | no |
<br />

### Tags
 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| tags | Additional resource tags. | map(string) | admin | no |
<br />

### Resource Group
 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| unique_name | Will concatenate a number at the end of your resource group name. | bool | true | yes |
| location | Cloud region in which to deploy the cluster resources. | string | - | yes |
<br />

### System Node Pool
 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| vm_size | Size of VM to use. | string | Standard_D2s_v3 | yes |
| node_count | Number of nodes to use. | number | 1 | yes |
<br />

### Additional Node Pool
 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| vm_size | Size of VM to use. | string | Standard_D2s_v3 | yes |
| enable_auto_scalling | Enable auto-scalling | bool | true | yes |
| min_count | Minimum number of nodes to use | number | 0 | yes |
| max_count | Maximum number of nodes to use. | number | 0 | yes |
<br />

### HPCC Image
 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| version | Version of the HPCC image to use.| string | latest | yes |
| root | Image root to use. | string | hpccsystems | yes |
| name | Image name to use. | string | platform-core | yes |
<br />

### Local or Remote Charts
If use_local_charts is true and local_chart is empty or set to null, the value for chart_version will be used as a branch/tag to locally clone the aforementioned chart version of hpcc-systems' helm_chart GitHub repo in the root module directory. That directory will not be tracked by git to avoid potential merge conflicts. <br />

 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| use_local_charts | Enable local or remote charts | bool | false | yes |
<br />

### HPCC Helm
 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| local_chart | Path to local chart directory name. Examples: ./HPCC-Platform, ./helm-chart. | string | - | yes |
| chart_version | Version of the charts to use. | string | - | yes |
| namespace | Namespace to use. | string | default | yes |
| name | Release name of the chart. | string | myhpcck8s | yes |
| values | List of desired state files to use similar to -f in CLI. | list(string) | - | yes |
<br />

### HPCC Storage Helm
 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| values | List of desired state files to use similar to -f in CLI. | list(string) | - | yes |
<br />

### HPCC ELK Helm
 Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| enabled | Enable ELK | bool | true | yes |
| name | name | Release name of the chart. | string | myhpccelk | yes |
| values | List of desired state files to use similar to -f in CLI. | list(string) | - | yes |
<br />

## Abstracted Modules

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
| recommendations | A list of security and cost recommendations for this deployment. |
<br />

## How to Run This?
1. Clone this repo.
2. Copy examples/admin.tfvars to terraform-azurerm-hpcc-aks/
3. Open terraform-azurerm-hpcc-aks/admin.tfvars file.
4. Set variables to your preferred values.
5. Save terraform-azurerm-hpcc-aks/admin.tfvars file.
6. Run: `terraform init`
7. Run: `terraform apply -var-file=admin.tfvars`
8. Type: `yes`
9. Copy aks_login command.
10. Run aks_login in your command line.
11. Accept to overwrite your current context.
12. List pods: `kubectl get pods`
13. List services: `kubectl get svc`
14. List persistent volume claims: `kubectl get pvc`
15. Delete cluster: `terraform destroy -var-file=admin.tfvars`
16. Type: `yes`