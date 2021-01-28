terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.18"
    }
  }

  backend "azurerm" {
    resource_group_name  = "Terra-rg"
    storage_account_name = "gmattaterrasa01"
    container_name       = "tfstate"
  }
}
