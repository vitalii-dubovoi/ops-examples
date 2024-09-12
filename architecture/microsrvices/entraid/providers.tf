terraform {
  required_version = ">=1.9.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.51, < 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.53.1"
    }
  }
}

provider "azuread" {
  tenant_id = "e9159e44-dd9a-43ad-929f-5a188a43eba7"
}

provider "azurerm" {
  features {}
}
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-al-dia-ops-canadacentral"
    storage_account_name = "saaldiaopscanadacentral"
    container_name       = "tfstate"
    key                  = "entraid.terraform.tfstate"
  }
}