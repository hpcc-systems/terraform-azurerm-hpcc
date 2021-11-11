## Introduction

This module deploys a virtual network using remote modules.
<br>

## Providers

| Name       | Version   |
| ---------- | --------- |
| azurerm    | >= 2.57.0 |
| random     | ~>3.1.0   |
| kubernetes | ~>2.2.0   |
<br>

## Supported Arguments
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

 | Name        | Description                                                       | Type   | Default | Required |
 | ----------- | ----------------------------------------------------------------- | ------ | ------- | :------: |
 | unique_name | Will concatenate a number at the end of your resource group name. | bool   | `true`  |   yes    |
 | location    | Cloud region in which to deploy the cluster resources.            | string | null    |   yes    |
<br>

Usage Example:
<br>

    resource_group = {
        unique_name = true
        location    = "canadacentral"
    }

<br>