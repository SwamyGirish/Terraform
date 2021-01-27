resource "azurerm_resource_group" "fe-rg" {
  name     = "${var.env}-Fe-rg"
  location = var.location_name
}

module "fe-vnet" {
  source              = "Azure/vnet/azurerm"
  resource_group_name = azurerm_resource_group.fe-rg.name
  address_space       = ["10.1.0.0/16"]
  subnet_prefixes     = ["10.1.0.0/24", "10.1.1.0/24"]
  subnet_names        = ["AzureFirewallSubnet", "${var.env}-Jbox-subnet"]
  tags                = null
  vnet_name           = "${var.env}-Fe-vnet"
  depends_on          = [azurerm_resource_group.fe-rg]
}

/* resource "azurerm_virtual_network" "fe-vnet" {
  name                = var.fe_vnet_name
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.fe-rg.location
  resource_group_name = azurerm_resource_group.fe-rg.name
}

resource "azurerm_subnet" "fe-azfw-subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.fe-rg.name
  virtual_network_name = azurerm_virtual_network.fe-vnet.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_subnet" "fe-jbox-subnet" {
  name                 = var.jb_sub_name
  resource_group_name  = azurerm_resource_group.fe-rg.name
  virtual_network_name = azurerm_virtual_network.fe-vnet.name
  address_prefixes     = ["10.1.1.0/24"]
} */

resource "azurerm_public_ip" "fe-pip" {
  name                = "${var.env}-Fw-pip01"
  resource_group_name = azurerm_resource_group.fe-rg.name
  location            = azurerm_resource_group.fe-rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "fe-fw" {
  name                = "${var.env}-Fw01"
  resource_group_name = azurerm_resource_group.fe-rg.name
  location            = azurerm_resource_group.fe-rg.location
  ip_configuration {
    name                 = "${var.env}-Fw01-config"
    subnet_id            = module.fe-vnet.vnet_subnets[0]
    public_ip_address_id = azurerm_public_ip.fe-pip.id
  }
}
