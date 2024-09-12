data "terraform_remote_state" "hub-network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-ops-canadacentral"
    storage_account_name = "saopscanadacentral"
    container_name       = "tfstate"
    key                  = "hub-network.terraform.tfstate"
  }
}
