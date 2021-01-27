terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 2.18"
    }
  }

  backend "azurerm" {}
}
