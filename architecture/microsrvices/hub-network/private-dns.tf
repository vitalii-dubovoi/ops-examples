# module "private_dns_zones" {
#   source   = "Azure/avm-res-network-privatednszone/azurerm"
#   version  = "0.1.2"
#   for_each = { for dns_zone in local.private_dns_zones : dns_zone.domain_name => dns_zone }

#   resource_group_name   = try(each.value.resource_group_name, azurerm_resource_group.hub.name)
#   domain_name           = each.key
#   virtual_network_links = try(each.value.virtual_network_links, null)
#   a_records             = try(each.value.a_records, {})
#   aaaa_records          = try(each.value.aaaa_records, {})
#   cname_records         = try(each.value.cname_records, {})
#   mx_records            = try(each.value.mx_records, {})
#   ptr_records           = try(each.value.ptr_records, {})
#   srv_records           = try(each.value.srv_records, {})
#   txt_records           = try(each.value.txt_records, {})

#   tags = local.default_tags
# }
