# rg fe-rg
# pip pub-ip01
# vnet - fe-vnet
# fw fw-01

resource "azurerm_resource_group" "fe-rg" {
  name     = var.fe_rg_name
  location = var.location_name
}

resource "azurerm_virtual_network" "fe-vnet" {
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
}

resource "azurerm_public_ip" "fe-pip" {
  name                = var.fw_pip_name
  resource_group_name = azurerm_resource_group.fe-rg.name
  location            = azurerm_resource_group.fe-rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "fe-fw" {
  name                = var.fw_name
  resource_group_name = azurerm_resource_group.fe-rg.name
  location            = azurerm_resource_group.fe-rg.location
  ip_configuration {
    name                 = "${var.fw_name}-config"
    subnet_id            = azurerm_subnet.fe-azfw-subnet.id
    public_ip_address_id = azurerm_public_ip.fe-pip.id
  }
}
