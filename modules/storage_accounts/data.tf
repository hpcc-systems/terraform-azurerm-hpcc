resource "null_resource" "get_host_public_ip" {
  provisioner "local-exec" {
    command = "curl ipconfig.org | tr -d '\\n' > public_ip.txt"
    interpreter = [ "/bin/bash", "-c" ]
  }

  triggers = {
    always_run = timestamp() # Force re-run on each apply
  }
}

data "local_file" "public_ip" {
  depends_on = [null_resource.get_host_public_ip]
  filename = "public_ip.txt"
}

data "azurerm_subscription" "current" {
}

