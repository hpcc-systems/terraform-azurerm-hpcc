# Azure - Storage Account for HPCC Systems
<br>

# ** DO NOT USE IN PRODUCTION **
<br>
<br>


## Introduction

This module deploys storage accounts for the HPCC Systems cloud native platform using remote modules.
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

### The `storage_accounts` block:
This block deploys the storage accounts for HPCC-Platform data planes. This block is required.

 | Name   | Description                                                                           | Type | Default | Valid Options | Required |
 | ------ | ------------------------------------------------------------------------------------- | ---- | ------- | ------------- | :------: |
 | dali   | The storage account for Dali data planes                                              | no   | any     | -             |    -     |
 | sasha  | The storage account for Sasha data planes                                             | no   | any     | -             |    -     |
 | common | The storage account for all data planes not defined in their specific storage account | no   | any     | -             |    -     |
 <br>

#### Only the following attributes are acceptable within a storage account definition:

 | Name                    | Description                                                                                            | Type   | Default     | Valid Options                                                            | Required |
 | ----------------------- | ------------------------------------------------------------------------------------------------------ | ------ | ----------- | ------------------------------------------------------------------------ | :------: |
 | access_tier             | Defines the access tier for `BlobStorage`, `FileStorage`, `Storage2` accounts.                         | string | Hot         | `Cool`, `Hot`                                                            |   yes    |
 | account_kind            | Defines the Kind of account. Changing this will destroy your data.                                     | string | `StorageV2` | `BlobStorage`. `BlockBlobStorage`, `FileStorage`, `Storage`, `StorageV2` |   yes    |
 | account_tier            | Defines the Tier to use for this storage account. Changing this will destroy your data.                | string | `Premium`   | `Standard`, `Premium`                                                    |   yes    |
 | enable_large_file_share | Enable Large File Share.                                                                               | bool   | `false`     | `false`, `true`                                                          |   yes    |
 | replication_type        | Defines the type of replication to use for this storage account. Changing this will destroy your data. | string | `LRS`       | `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS`, `RAGZRS`                           |   yes    |
 | shares                  | Defines the file shares for the storage account                                                        | yes    | `map(any)`  | -                                                                        |    -     |
<br>

#### Only the following attributes are acceptable within a share definition:

 | Name             | Description                                                              | Type   | Default | Valid Options                                           | Required |
 | ---------------- | ------------------------------------------------------------------------ | ------ | ------- | ------------------------------------------------------- | :------: |
 | quota            | The size of the share or HPCC data plane                                 | number | -       | -                                                       |   yes    |
 | permissions      | The set of permissions for the share or data plane                       | string | `rwdl`  | one or a combination of `r`, `w`, `d`, `l` (ex. `rwdl`) |   yes    |
 | access_tier      | As described above                                                       |
 | enabled_protocol | The network file sharing protocol to use for the share                   | string | `SMB`   | `SMB`, `NFS`                                            |   yes    |
 | sub_path         | The sub path for the HPCC data plane                                     | string | -       | -                                                       |   yes    |
 | category         | The category for the HPCC data plane                                     | string | -       | -                                                       |   yes    |
 | start            | The time at which the access policies should be valid from for the share | string | -       | `ISO8601` format only                                   |    no    |
 | expiry           | The time at which the access policies should be expired for the share    | string | -       | `ISO8601` format only                                   |    no    |
 <br>
 
Usage Example:
<br>

    storage_accounts = {
        # do not change the names of the keys
        dali = {
            access_tier               = "Hot"
            account_kind              = "FileStorage"
            account_tier              = "Premium"
            replication_type          = "LRS"
            enable_large_file_share   = true
            shared_access_key_enabled = true
            # auto_approval_subscription_ids = []

            shares = {
                dali = {
                    quota            = 100
                    permissions      = "rwdl"
                    access_tier      = "Premium"     # Hot, Cool, TransactionOptimized, Premium
                    enabled_protocol = "SMB"         # SMB, NFS
                    sub_path         = "dalistorage" # do not change
                    category         = "dali"        # do not change
                    # start = "2022-06-13T22:31:31.612Z"
                    # expiry = "2022-06-14T22:31:31.612Z"
                }
            }
        }

        sasha = {
            access_tier               = "Hot"
            account_kind              = "FileStorage"
            account_tier              = "Premium"
            replication_type          = "LRS"
            enable_large_file_share   = true
            shared_access_key_enabled = true
            # auto_approval_subscription_ids = []

            shares = {
                sasha = {
                    quota            = 100
                    permissions      = "rwdl"
                    access_tier      = "Premium" # Hot, Cool, TransactionOptimized, Premium
                    enabled_protocol = "SMB"     # SMB, NFS
                    sub_path         = "sasha"   # do not change
                    category         = "sasha"   # do not change
                    # start = "2022-06-13T22:31:31.612Z"
                    # expiry = "2022-06-14T22:31:31.612Z"
                }
            }
        }

        common = {
            access_tier               = "Hot"
            account_kind              = "StorageV2"
            account_tier              = "Standard"
            replication_type          = "LRS"
            shared_access_key_enabled = true
            enable_large_file_share   = true
            # auto_approval_subscription_ids = []

            shares = {
                data = {
                    quota            = 100
                    permissions      = "rwdl"
                    access_tier      = "Premium"   # Hot, Cool, TransactionOptimized, Premium
                    enabled_protocol = "SMB"       # SMB, NFS
                    sub_path         = "hpcc-data" # do not change
                    category         = "data"      # do not change
                    # start = "2022-06-13T22:31:31.612Z"
                    # expiry = "2022-06-14T22:31:31.612Z"
                }

                dll = {
                    quota            = 100
                    permissions      = "rwdl"
                    access_tier      = "Premium" # Hot, Cool, TransactionOptimized, Premium
                    enabled_protocol = "SMB"     # SMB, NFS
                    sub_path         = "queries" # do not change
                    category         = "dll"     # do not change
                    # start = "2022-06-13T22:31:31.612Z"
                    # expiry = "2022-06-14T22:31:31.612Z"
                }

                mydropzone = {
                    quota            = 100
                    permissions      = "rwdl"
                    access_tier      = "Premium"  # Hot, Cool, TransactionOptimized, Premium
                    enabled_protocol = "SMB"      # SMB, NFS
                    sub_path         = "dropzone" # do not change
                    category         = "lz"       # do not change
                    # start = "2022-06-13T22:31:31.612Z"
                    # expiry = "2022-06-14T22:31:31.612Z"
                }
            }
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