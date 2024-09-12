terraform {
  required_version = ">=1.9.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.51, < 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "terraform_remote_state" "hub-network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-ops-canadacentral"
    storage_account_name = "saopscanadacentral"
    container_name       = "tfstate"
    key                  = "app-development.terraform.tfstate"
  }
}
