resource "null_resource" "get_host_public_ip" {
  provisioner "local-exec" {
    command = "curl ipconfig.org"
  }

  triggers = {
    always_run = timestamp() # Force re-run on each apply
  }
}

data "azurerm_subscription" "current" {
}

