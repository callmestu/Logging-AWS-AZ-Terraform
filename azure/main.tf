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
  location = "eastus" #var.location
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
resource "azurerm_automation_account" "automation_account" {
  name                = "var.automation_account_name"
  location            = azurerm_resource_group.PIM_VPC.location
  resource_group_name = azurerm_resource_group.PIM_VPC.name

  sku_name = "Basic"

  tags = {
    environment = "development"
  }
}
resource "azurerm_automation_runbook" "var.runbook_name" {
  name                    = "Get-AzureVMTutorial"
  location                = azurerm_resource_group.azurePimAwsSSO.location
  resource_group_name     = azurerm_resource_group.azurePimAwsSSO.name
  automation_account_name = azurerm_automation_account.automation_account.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "Powershell sync script with secrets as variables"
  runbook_type            = "PowerShellWorkflow"

  publish_content_link {
    uri = "https://raw.githubusercontent.com/callmestu/Logging-AWS-AZ-Terraform/main/azure/aad_sync.ps1     "
  }
}