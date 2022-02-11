# Azure - Storage Account for HPCC Systems
<br>

# ** DO NOT USE IN PRODUCTION **
<br>
<br>


## Introduction

This module deploys a storage account for the HPCC Systems cloud native platform using remote modules.
<br>

## Providers

| Name    | Version   |
| ------- | --------- |
| azurerm | >= 2.57.0 |
| random  | ~>3.1.0   |
<br>

### The `admin` block:
This block contains information on the user who is deploying the cluster. This is used as tags and part of some resource names to identify who deployed a given resource and how to contact that user. This block is required.

| Name  | Description                  | Type   | Default | Required |
| ----- | ---------------------------- | ------ | ------- | :------: |
| name  | Name of the admin.           | string | -       |   yes    |
| email | Email address for the admin. | string | -       |   yes    |

<br>
Usage Example:
<br>

    admin = {
        name  = "Example"
        email = "example@hpccdemo.com"
    }

<br>

### The `disable_naming_conventions` block:
When set to `true`, this attribute drops the naming conventions set forth by the python module. This attribute is optional.

 | Name                       | Description                 | Type | Default | Required |
 | -------------------------- | --------------------------- | ---- | ------- | :------: |
 | disable_naming_conventions | Disable naming conventions. | bool | `false` |    no    |
<br>

### The `metadata` block:
TThe arguments in this block are used as tags and part of resources’ names. This block can be omitted when disable_naming_conventions is set to `true`.

 | Name                | Description                  | Type   | Default | Required |
 | ------------------- | ---------------------------- | ------ | ------- | :------: |
 | project_name        | Name of the project.         | string | ""      |   yes    |
 | product_name        | Name of the product.         | string | hpcc    |    no    |
 | business_unit       | Name of your bussiness unit. | string | ""      |    no    |
 | environment         | Name of the environment.     | string | ""      |    no    |
 | market              | Name of market.              | string | ""      |    no    |
 | product_group       | Name of product group.       | string | ""      |    no    |
 | resource_group_type | Resource group type.         | string | ""      |    no    |
 | sre_team            | Name of SRE team.            | string | ""      |    no    |
 | subscription_type   | Subscription type.           | string | ""      |    no    |
<br>

Usage Example:
<br>

    metadata = {    
        project             = "hpccdemo"
        product_name        = "example"
        business_unit       = "commercial"
        environment         = "sandbox"
        market              = "us"
        product_group       = "contoso"
        resource_group_type = "app"
        sre_team            = "hpccplatform"
        subscription_type   = "dev"
    }

<br>

### The `tags` argument:
The tag attribute can be used for additional tags. The tags must be key value pairs. This block is optional.

 | Name | Description               | Type        | Default | Required |
 | ---- | ------------------------- | ----------- | ------- | :------: |
 | tags | Additional resource tags. | map(string) | admin   |    no    |
<br>

### The `resource_group` block:
This block creates a resource group (like a folder) for your resources. This block is required.

 | Name        | Description                                                       | Type | Default | Required |
 | ----------- | ----------------------------------------------------------------- | ---- | ------- | :------: |
 | unique_name | Will concatenate a number at the end of your resource group name. | bool | `true`  |   yes    |
<br>

Usage Example:
<br>

    resource_group = {
        unique_name = true
        location    = "canadacentral"
    }

<br>

### The `virtual_network` block:
This block imports metadata of a virtual network deployed outside of this project. This block is optional.

 | Name              | Description                             | Type   | Default | Required |
 | ----------------- | --------------------------------------- | ------ | ------- | :------: |
 | private_subnet_id | The ID of the private subnet.           | string | -       |   yes    |
 | public_subnet_id  | The ID of the public subnet.            | string | -       |   yes    |
 | route_table_id    | The ID  of the route table for the AKS. | string | -       |   yes    |
 | location          | The location of the virtual network     | string | -       |   yes    |
<br>

Usage Example:
<br>

    virtual_network = {
        private_subnet_id = ""
        public_subnet_id  = ""
        route_table_id    = ""
        location          = ""
    }

<br>

### The `storage` block:
This block deploys the HPCC persistent volumes. This block is required.

 | Name                    | Description                                                                                            | Type   | Default     | Valid Options                                                            | Required |
 | ----------------------- | ------------------------------------------------------------------------------------------------------ | ------ | ----------- | ------------------------------------------------------------------------ | :------: |
 | access_tier             | Defines the access tier for `BlobStorage`, `FileStorage`, `Storage2` accounts.                         | string | Hot         | `Cool`, `Hot`                                                            |   yes    |
 | account_kind            | Defines the Kind of account. Changing this will destroy your data.                                     | string | `StorageV2` | `BlobStorage`. `BlockBlobStorage`, `FileStorage`, `Storage`, `StorageV2` |   yes    |
 | account_tier            | Defines the Tier to use for this storage account. Changing this will destroy your data.                | string | `Premium`   | `Standard`, `Premium`                                                    |   yes    |
 | enable_large_file_share | Enable Large File Share.                                                                               | bool   | `false`     | `false`, `true`                                                          |   yes    |
 | replication_type        | Defines the type of replication to use for this storage account. Changing this will destroy your data. | string | `LRS`       | `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS`, `RAGZRS`                           |   yes    |
<br>

Usage Example:
<br>

    storage = {
        access_tier              = "Hot"
        account_kind             = "StorageV2"
        account_tier             = "Standard"
        account_replication_type = "LRS"

        quotas = {
            dali  = 3
            data  = 2
            dll   = 2
            lz    = 2
            sasha = 5
        }
    }

<br>

## Usage
<ol>
<li> 

Clone this repo: `git clone https://github.com/gfortil/terraform-azurerm-hpcc-storage.git`. </li>

<li>Linux and MacOS</li>
<ol>
<li> 

Change directory to terraform-azurerm-hpcc-storage: `cd terraform-azurerm-hpcc-storage` </li>
<li> 

Copy examples/admin.tfvars to terraform-azurerm-hpcc-storage: `cp examples/admin.tfvars` </li>
</ol>
<li>Windows OS</li>
<ol>
<li> 
    
Change directory to terraform-azurerm-hpcc-storage: `cd terraform-azurerm-hpcc-storage` </li>
<li> 

Copy examples/admin.tfvars to terraform-azurerm-hpcc-storage: `copy examples/admin.tfvars` </li>
</ol>
<li> 

Open `terraform-azurerm-hpcc-storage/admin.tfvars` file. </li>
<li> 

Set attributes to your preferred values. </li>
<li> 

Save `terraform-azurerm-hpcc-storage/admin.tfvars` file. </li>
<li> 

Run `terraform init`. This step is only required before your first `terraform apply`. </li>
<li> 

Run `terraform apply -var-file=admin.tfvars` or `terraform apply -var-file=admin.tfvars -auto-approve`. </li>
<li> 

Type `yes` if you didn't pass the flag `-auto-approve`. </li>
</ol>