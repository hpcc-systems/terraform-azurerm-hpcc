terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.74.0"
    }
  }
}

provider "random" {
}

provider "azurerm" {
  features {}
}

