terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.42.0"
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
  location = "eastus"         #var.location
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
resource "azurerm_automation_account" "automationAccount" {
  name                = var.automation_account_name
  location            = azurerm_resource_group.azurePimAwsSSO.location
  resource_group_name = azurerm_resource_group.azurePimAwsSSO.name

  sku_name = "Basic"

  tags = {
    environment = "var.environment"
  }
}
resource "azurerm_automation_runbook" "runbook" {
  name                    = var.runbook_name
  location                = azurerm_resource_group.azurePimAwsSSO.location
  resource_group_name     = azurerm_resource_group.azurePimAwsSSO.name
  automation_account_name = azurerm_automation_account.automationAccount.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "Powershell sync script with secrets as variables"
  runbook_type            = "PowerShellWorkflow"

  publish_content_link {
    uri = "https://raw.githubusercontent.com/callmestu/Logging-AWS-AZ-Terraform/main/azure/aad_sync.ps1"
  }
}

resource "azurerm_log_analytics_solution" "LogAnSolution" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.azurePimAwsSSO.location
  resource_group_name   = azurerm_resource_group.azurePimAwsSSO.name
  workspace_resource_id = azurerm_log_analytics_workspace.logAnalytics.id
  workspace_name        = azurerm_log_analytics_workspace.logAnalytics.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

#need vars updated below
resource "azurerm_logic_app_workflow" "example" {
  name                = "${var.prefix}-logicapp"
  location            = "${azurerm_resource_group.example.location}"
  resource_group_name = "${azurerm_resource_group.example.name}"
}

resource "azurerm_logic_app_trigger_recurrence" "hourly" {
  name         = "run-every-hour"
  logic_app_id = "${azurerm_logic_app_workflow.example.id}"
  frequency    = "Hour"
  interval     = 1
}
