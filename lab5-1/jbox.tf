/*
rg jbox-rg
vm jbox-vm01
nic jbox-nic01
nsg jbox-nsg
*/

resource "azurerm_resource_group" "jbox-rg" {
  name     = var.jb_rg_name
  location = var.location_name
}

module "jbox-vm" {
  source         = "../modules/compute"
  vm_name        = var.jb_vm_name
  subnet_id      = azurerm_subnet.fe-jbox-subnet.id
  location       = azurerm_resource_group.jbox-rg.location
  rg_name        = azurerm_resource_group.jbox-rg.name
  admin_password = var.admin_password
}

/*resource "azurerm_network_interface" "jbox-nic01" {
  name                = "${var.jb_vm_name}-nic01"
  location            = azurerm_resource_group.jbox-rg.location
  resource_group_name = azurerm_resource_group.jbox-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.fe-jbox-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "jbox-nsg" {
  name                = "${var.jb_vm_name}-nsg01"
  location            = azurerm_resource_group.jbox-rg.location
  resource_group_name = azurerm_resource_group.jbox-rg.name
} */

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

/* resource "azurerm_virtual_machine" "jbox-vm01" {
  name                  = "${var.jb_vm_name}-vm01"
  location              = azurerm_resource_group.jbox-rg.location
  resource_group_name   = azurerm_resource_group.jbox-rg.name
  network_interface_ids = [azurerm_network_interface.jbox-nic01.id]
  vm_size               = "Standard_B2S"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.jb_vm_name}-osdisk"
    managed_disk_type = "StandardSSD_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${var.jb_vm_name}-vm01"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_windows_config {
    enable_automatic_upgrades = true
    provision_vm_agent        = true
  }
} */
