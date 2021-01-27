# nic_private_ip, vm_id, nsg_name

output "vmnic_private_ip" {
  value = azurerm_network_interface.compute.private_ip_address
}

output "vmnic_id" {
  value = azurerm_network_interface.compute.id
}

output "vm_id" {
  value = azurerm_virtual_machine.compute.id
}

output "nsg_name" {
  value = azurerm_network_security_group.compute.name
}

output "nsg_id" {
  value = azurerm_network_security_group.compute.id
}
