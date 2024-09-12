locals {
  data_users = { for user in data.azuread_users.icemobile_users.users : user.user_principal_name => user }
  aad_groups = [
    {
      description  = "Admins for AKS Dev",
      display_name = "Al Dia AKS Dev Admins"
      members = [
        local.data_users["vitalii.dubovoi@IceMobile.com"].object_id
      ]
    },
    {
      display_name = "Al Dia AKS Dev Users"
    },
    {
      display_name = "Al Dia ArgoCD Admin"
      members = [
        local.data_users["vitalii.dubovoi@IceMobile.com"].object_id
      ]
    }
  ]
}


