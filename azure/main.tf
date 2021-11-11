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
  name     = "azurePimAwsSSO" #"${var.prefix}-resources"
  location = "North America"  #var.location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "PIM_VPC" {
  name                = "PIM_VPC"
  resource_group_name = azurerm_resource_group.azurePimAwsSSO.name
  location            = azurerm_resource_group.azurePimAwsSSO.location
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_log_analytics_workspace" "logAnalytics" {
  name                = "${var.prefix}-laworkspace"
  location            = azurerm_resource_group.azurePimAwsSSO.location
  resource_group_name = azurerm_resource_group.azurePimAwsSSO.name
  sku                 = "PerGB2018"
}
