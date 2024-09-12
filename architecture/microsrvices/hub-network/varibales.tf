variable "location" {
  description = "The Azure Region in which all resources will be created."
  default     = "canadacentral"
}

variable "environment" {
  description = "The environment in which the resources will be created."
  default     = "dev"
}

variable "project" {
  description = "The name of the project."
  default     = "al-dia"
}

variable "purpose" {
  description = "Purpose of theese resources is to create a hub network"
  default     = "hub-vnet"
}