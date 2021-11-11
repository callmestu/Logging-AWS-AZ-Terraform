variable "location" {
  type        = string
  description = "Which region or availability zone to use."
  default     = "North America"
}
variable "prefix" {
  type        = string
  description = "This will be the begining of the names used in the resources and instances."
  default     = "dev-logInfra"
}

