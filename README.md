# Azure - HPCC AKS Root Module

## Introduction

This module will deploy an HPCC AKS cluster using other abstracted modules
<br />

<!--- BEGIN_TF_DOCS --->
## Providers

| Name | Version |
|------|---------|
| azurerm | >= 2.57.0 |
| random | ~>3.1.0 |
| kubernetes | ~>2.2.0 |
| helm | ~>2.1.2 |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| admin | Name of the admin | string | - | yes |

Note: See the modules listed below for their respective input descriptions.


## Abstracted Modules

| Name | Description | URL | Required |
|------|-------------|-----|:----------:|
| subscription | Queries enabled azure subscription from host machine | github.com/Azure-Terraform/terraform-azurerm-subscription-data.git | yes |
| naming | Enforces naming conventions | - | yes |
| metadata | Provides metadata | github.com/Azure-Terraform/terraform-azurerm-metadata.git | yes |
| resource_group | Creates a resource group | github.com/Azure-Terraform/terraform-azurerm-resource-group.git | yes |
| virtual_network | Creates a virtual network | github.com/Azure-Terraform/terraform-azurerm-virtual-network.git | yes |
| cheapest_spot_region | Returns the region name with the cheapest instance based on a given size | github.com/gfortil/terraform-azurerm-cheapest-region.git | no |
| kubernetes | Creates an Azure Kubernetes Service Cluster | github.com/Azure-Terraform/terraform-azurerm-kubernetes.git | yes |
| hpcc_helm | Deploy all currently supported HPCC helm charts (aks, pv and elk) | - | yes |


## Outputs

| Name | Description | 
|------|-------------|
| aks_login | Outputs the login information to connect to the k8s cluster |