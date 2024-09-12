# resource "azuread_group" "aldia_security_groups" {
#   for_each = { for key, value in local.aad_groups : value.display_name => value }

#   display_name     = each.key
#   description      = try(each.value.description, null)
#   security_enabled = try(each.value.mail_enabled, true)
#   members          = try(each.value.members, [])
# }


# resource "azurerm_role_assignment" "example" {
#   scope                = "/subscriptions/7f5cc8f5-7f30-436f-96b5-1bf4332c6a2b/resourcegroups/rg-al-dia-mexicocentral-dev/providers/Microsoft.ContainerService/managedClusters/aks-al-dia-mexicocentral-dev"
#   role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
#   principal_id         = azuread_group.aldia_security_groups["Al Dia AKS Dev Admins"].object_id
# }


