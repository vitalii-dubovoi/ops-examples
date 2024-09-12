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
  default     = "doppio"
}

variable "logical_enviroment" {
  description = "The logical environment in which the resources will be created."
  default     = "development, qa, staging"
}