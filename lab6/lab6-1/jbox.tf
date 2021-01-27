resource "azurerm_resource_group" "jbox-rg" {
  name     = "${var.env}-Jbox-rg"
  location = var.location_name
}

module "jbox-vm" {
  source         = "../modules/compute"
  vm_name        = "${var.env}-Jbox"
  subnet_id      = module.fe-vnet.vnet_subnets[1]
  location       = azurerm_resource_group.jbox-rg.location
  rg_name        = azurerm_resource_group.jbox-rg.name
  admin_password = data.azurerm_key_vault_secret.kv-secrete.value
}

resource "azurerm_network_security_rule" "jbox-nsg-rule" {
  name                        = "jbox"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "${module.jbox-vm.vmnic_private_ip}/32"
  resource_group_name         = azurerm_resource_group.jbox-rg.name
  network_security_group_name = module.jbox-vm.nsg_name
}

resource "azurerm_network_interface_security_group_association" "jbox-nsg01-nsgassoc" {
  network_interface_id      = module.jbox-vm.vmnic_id
  network_security_group_id = module.jbox-vm.nsg_id
}
