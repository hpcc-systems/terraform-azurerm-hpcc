data "http" "host_ip" {
  url = "https://ifconfig.me"
}

data "azurerm_subscription" "current" {
}

data "external" "vnet" {
  count   = can(var.virtual_network.private_subnet_id) && can(var.virtual_network.public_subnet_id) ? 0 : 1
  program = ["python", "../virtual_network/bin/run.py"]

  query = {
    data_file = "../virtual_network/bin/outputs.json"
  }
}

