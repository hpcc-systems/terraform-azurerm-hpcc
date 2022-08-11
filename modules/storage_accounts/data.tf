data "http" "host_ip" {
  url = "https://ifconfig.me"
}

data "azurerm_subscription" "current" {
}

