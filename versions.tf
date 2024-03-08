terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.71.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.1.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.5.1"
    }
  }
  required_version = ">=0.15.0"
}
