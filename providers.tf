provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = module.kubernetes[0].kube_config.host
  client_certificate     = base64decode(module.kubernetes[0].kube_config.client_certificate)
  client_key             = base64decode(module.kubernetes[0].kube_config.client_key)
  cluster_ca_certificate = base64decode(module.kubernetes[0].kube_config.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.kubernetes[0].kube_config.host
    client_certificate     = base64decode(module.kubernetes[0].kube_config.client_certificate)
    client_key             = base64decode(module.kubernetes[0].kube_config.client_key)
    cluster_ca_certificate = base64decode(module.kubernetes[0].kube_config.cluster_ca_certificate)
  }
}
