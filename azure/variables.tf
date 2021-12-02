variable "location" {
  type        = string
  description = "Which region or availability zone to use"
  default     = "eastus"
}
variable "prefix" {
  type        = string
  description = "This will be the begining of the names used in the resources and instances"
  default     = "dev-logInfra"
}
variable "logAnalytics_name" {
  type        = string
  description = "This will be used in the Log Analytics AKA Azure Monitor resource name"
  default     = "aadLogAnalytics"
  # var.prefix-LogAnalytics
}
variable "resource_group_name" {
  type        = string
  description = "A resource group is needed and it needs a name - this may end up as auto generated from some other variable"
  default     = "azurePimAwsSSO"
}
variable "automation_account_name" {
  type        = string
  description = "Name for AZ automation account needed to trigger run book"
  default     = "aws-sso"
}
variable "runbook_name" {
  type        = string
  description = "Name for AZ runbook containing the AAD sync script"
  default     = "AwsSSO (aws-sso/AwsSSO)"
}
variable "instance_count" {
  type        = number
  description = "This will determine the number of resources created"
  default     = 1
}
variable "instance_size" {
  type        = string
  description = "This will determine the VM machine size used in a particular environment"
  default     = "Standard_DS1_v2"
}
variable "environment" {
  type        = string
  description = "This will determine type of environment (prd, dev, tst, stg) created"
  default     = "dev"
}