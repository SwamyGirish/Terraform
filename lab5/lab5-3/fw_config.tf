resource "azurerm_virtual_network_peering" "fe-to-be-peering" {
  name                      = "fe-be-vnet-pering"
  resource_group_name       = azurerm_resource_group.fe-rg.name
  virtual_network_name      = module.fe-vnet.vnet_name
  remote_virtual_network_id = module.be-vnet.vnet_id
}

resource "azurerm_virtual_network_peering" "be-to-fe-peering" {
  name                      = "be-fe-vnet-pering"
  resource_group_name       = azurerm_resource_group.be-rg.name
  virtual_network_name      = module.be-vnet.vnet_name
  remote_virtual_network_id = module.fe-vnet.vnet_id
}

resource "azurerm_firewall_nat_rule_collection" "fe-fw-rule-collection" {
  name                = "nat-rules"
  azure_firewall_name = azurerm_firewall.fe-fw.name
  resource_group_name = azurerm_resource_group.fe-rg.name
  priority            = 100
  action              = "Dnat"

  rule {
    name                  = "web-rule"
    source_addresses      = ["*"]
    destination_ports     = ["80"]
    destination_addresses = [azurerm_public_ip.fe-pip.ip_address]
    translated_port       = 80
    translated_address    = module.web-vm.vmnic_private_ip
    protocols             = ["TCP"]
  }

  rule {
    name                  = "jbox-rule"
    source_addresses      = ["*"]
    destination_ports     = ["5000"]
    destination_addresses = [azurerm_public_ip.fe-pip.ip_address]
    translated_port       = 3389
    translated_address    = module.jbox-vm.vmnic_private_ip
    protocols             = ["TCP"]
  }
}

