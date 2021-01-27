resource "azurerm_resource_group" "be-rg" {
  name     = "${var.env}-Be-rg"
  location = var.location_name
}

module "be-vnet" {
  source              = "Azure/vnet/azurerm"
  version             = "2.0.0"
  vnet_name           = "${var.env}-be-vnet"
  resource_group_name = azurerm_resource_group.be-rg.name
  address_space       = ["10.2.0.0/16"]
  subnet_prefixes     = ["10.2.0.0/24"]
  subnet_names        = ["${var.env}-be-Web-subnet"]
  tags                = null
  depends_on          = [azurerm_resource_group.be-rg]
}

/* resource "azurerm_virtual_network" "be-vnet" {
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
} */

module "web-vm" {
  source         = "../modules/compute"
  vm_name        = "${var.env}-Web"
  subnet_id      = module.be-vnet.vnet_subnets[0]
  location       = azurerm_resource_group.be-rg.location
  rg_name        = azurerm_resource_group.be-rg.name
  admin_password = var.admin_password
}

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
