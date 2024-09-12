data "azuread_users" "icemobile_users" {
  return_all = true
}



data "azurerm_subscription" "primary" {
}

# output "users" {
#   value = data.azuread_users.icemobile_users
# }

# output "names" {
#   value = local.data_users
# }
