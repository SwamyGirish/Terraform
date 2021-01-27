/*
rg be-rg
vnet web-vnet
subnet web-subnet
nsg webserver-nsg
nic webserver-nic
vm webserver-vm01 
*/

resource "azurerm_resource_group" "be-rg" {
  name     = var.be_rg_name
  location = var.location_name
}

module "web-vm" {
  source         = "../modules/compute"
  vm_name        = var.web_vm_name
  subnet_id      = azurerm_subnet.be-web-subnet.id
  location       = azurerm_resource_group.be-rg.location
  rg_name        = azurerm_resource_group.be-rg.name
  admin_password = var.admin_password
}

resource "azurerm_virtual_network" "be-vnet" {
  name                = var.be_vnet_name
  resource_group_name = azurerm_resource_group.be-rg.name
  location            = azurerm_resource_group.be-rg.location
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "be-web-subnet" {
  name                 = var.be_web_sub_name
  resource_group_name  = azurerm_resource_group.be-rg.name
  virtual_network_name = azurerm_virtual_network.be-vnet.name
  address_prefixes     = ["10.2.0.0/24"]
}

/* resource "azurerm_network_interface" "be-webserver-nic01" {
  name                = "${var.web_vm_name}-nic01"
  location            = azurerm_resource_group.be-rg.location
  resource_group_name = azurerm_resource_group.be-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.be-web-subnet.id
    private_ip_address_allocation = "Dynamic"

  }

}

resource "azurerm_network_security_group" "be-webserver-nsg01" {
  name                = "${var.web_vm_name}-nsg01"
  location            = azurerm_resource_group.be-rg.location
  resource_group_name = azurerm_resource_group.be-rg.name

} */

resource "azurerm_network_security_rule" "be-websever-nsg01-secrule-web" {
  name                        = "web"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "${module.web-vm.vmnic_private_ip}/32"
  resource_group_name         = azurerm_resource_group.be-rg.name
  network_security_group_name = module.web-vm.nsg_name
}

resource "azurerm_network_security_rule" "be-webserver-nsg01-secule-rdp" {
  name                        = "rdp"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "${module.jbox-vm.vmnic_private_ip}/32"
  destination_address_prefix  = "${module.web-vm.vmnic_private_ip}/32"
  resource_group_name         = azurerm_resource_group.be-rg.name
  network_security_group_name = module.web-vm.nsg_name
}

resource "azurerm_network_interface_security_group_association" "be-webserver-nsg01-nsgassoc" {
  network_interface_id      = module.web-vm.vmnic_id
  network_security_group_id = module.web-vm.nsg_id
}

/* resource "azurerm_virtual_machine" "be-webserver-vm01" {
  name                  = "${var.web_vm_name}-vm01"
  location              = azurerm_resource_group.be-rg.location
  resource_group_name   = azurerm_resource_group.be-rg.name
  network_interface_ids = [azurerm_network_interface.be-webserver-nic01.id]
  vm_size               = "Standard_B2s"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"

  }

  storage_os_disk {
    name              = "${var.web_vm_name}-osdisk"
    managed_disk_type = "StandardSSD_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"

  }

  os_profile {
    computer_name  = "${var.web_vm_name}-vm01"
    admin_username = var.admin_username
    admin_password = var.admin_password

  }

  os_profile_windows_config {
    enable_automatic_upgrades = true
    provision_vm_agent        = true

  }

} */

resource "azurerm_virtual_machine_extension" "be-webserver-vm01-csextension" {
  name                 = "csextension-iis"
  virtual_machine_id   = module.web-vm.vm_id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  settings             = <<SETTINGS
    {
        "commandToExecute": "powershell Install-WindowsFeature -name web-server -IncludeManagementTools"
    }
SETTINGS
}
