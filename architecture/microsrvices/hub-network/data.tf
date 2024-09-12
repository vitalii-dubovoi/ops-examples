# data "terraform_remote_state" "ms-dev" {
#   backend = "azurerm"
#   config = {
#     resource_group_name  = "rg-al-dia-ops-canadacentral"
#     storage_account_name = "saaldiaopscanadacentral"
#     container_name       = "tfstate"
#     key                  = "ms.dev.terraform.tfstate"
#   }
# }
