output "firewall-public-ip" {
  value = azurerm_public_ip.fe-pip.ip_address
}

output "webserver-internal-ip" {
  value = module.web-vm.vmnic_private_ip
}


