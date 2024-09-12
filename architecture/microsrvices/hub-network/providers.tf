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

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-al-dia-ops-canadacentral"
    storage_account_name = "saaldiaopscanadacentral"
    container_name       = "tfstate"
    key                  = "hub-network.terraform.tfstate"
  }
}
