terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "azurePimAwsSSO" {
  name     = "azurePimAwsSSO"
  location = "North America"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "PIM_VPC" {
  name                = "PIM_VPC"
  resource_group_name = azurerm_resource_group.PIM_VPC.name
  location            = azurerm_resource_group.PIM_VPC.location
  address_space       = ["10.0.0.0/16"]
}
