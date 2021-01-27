data "azurerm_key_vault" "kv" {
  name                = "gmatta-kvault-01"
  resource_group_name = "terra-rg"
}

data "azurerm_key_vault_secret" "kv-secrete" {
  name         = "admin-password"
  key_vault_id = data.azurerm_key_vault.kv.id
}

