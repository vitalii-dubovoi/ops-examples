resource "azurerm_resource_group" "core" {
  name     = module.naming.resource_group.name
  location = var.location

  tags = local.default_tags
}


module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.4.0"

  address_space       = ["10.0.0.0/20"]
  location            = var.location
  name                = module.naming.virtual_network.name
  resource_group_name = azurerm_resource_group.core.name
  subnets = {
    snet-aks-nodepool-01 = {
      name             = "snet-aks-nodepool-01"
      address_prefixes = ["10.0.1.0/28"]
    }
    snet-aks-nodepool-pods-01 = {
      name             = "snet-aks-nodepool-pods-01"
      address_prefixes = ["10.0.2.0/23"]
      delegation = [{
        name = "aks-delegation"
        service_delegation = {
          name    = "Microsoft.ContainerService/managedClusters"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }]
    }
    snet-gw-01 = {
      name             = "snet-gw-01"
      address_prefixes = ["10.0.14.0/24"]
    }
  }
}

resource "azurerm_user_assigned_identity" "aks" {
  location            = azurerm_resource_group.core.location
  name                = "${module.naming.kubernetes_cluster.name}-identity"
  resource_group_name = azurerm_resource_group.core.name
}

module "aks" {
  source  = "Azure/aks/azurerm"
  version = "9.1.0"
  # Kubernetes general configuration
  prefix                            = "${var.project}-${var.environment}"
  cluster_name                      = module.naming.kubernetes_cluster.name
  resource_group_name               = azurerm_resource_group.core.name
  location                          = azurerm_resource_group.core.location
  automatic_channel_upgrade         = "patch"
  kubernetes_version                = "1.30"
  local_account_disabled            = true
  identity_ids                      = [azurerm_user_assigned_identity.aks.id]
  identity_type                     = "UserAssigned"
  rbac_aad                          = true
  rbac_aad_azure_rbac_enabled       = true
  role_based_access_control_enabled = true
  rbac_aad_managed                  = true
  agents_availability_zones         = []     # If you want to spread the agents across availability zones, provide the list of zones here 
  sku_tier                          = "Free" #The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, Standard and Premium
  network_plugin                    = "azure"
  network_policy                    = "azure"
  net_profile_service_cidr          = "10.5.0.0/16"
  net_profile_dns_service_ip        = "10.5.0.10"
  log_analytics_workspace_enabled   = false
  workload_identity_enabled         = true
  oidc_issuer_enabled               = true
  private_cluster_enabled           = true
  private_dns_zone_id               = module.private_dns_zones["privatelink.canadacentral.azmk8s.io"].resource.id
  green_field_application_gateway_for_ingress = {
    name        = "ingress"
    #subnet_cidr = module.vnet.subnets["snet-gw-01"].resource.body.properties.addressPrefixes[0]
    subnet_id   = module.vnet.subnets["snet-gw-01"].resource.id
  }
  # Node pool configurations
  # TODO: Add maintanance windows for cluster and node pools
  vnet_subnet_id      = module.vnet.subnets["snet-aks-nodepool-01"].resource.id
  pod_subnet_id       = module.vnet.subnets["snet-aks-nodepool-pods-01"].resource.id
  agents_pool_name    = "system"
  enable_auto_scaling = true
  agents_size         = "Standard_D2s_v3"
  agents_count        = 1
  agents_max_count    = 1
  agents_min_count    = 1
  # Node pool for the application workloads
  # node_pools = local.node_pools
  tags = local.default_tags

  # We have to explicitly depend on the resource group. Beceause the module uses data.azurerm_resource_group reference to it.
  depends_on = [azurerm_resource_group.core]
}

resource "azurerm_role_assignment" "aks_private_dns_zone_contributor" {
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
  scope                = module.private_dns_zones["privatelink.canadacentral.azmk8s.io"].resource.id
  role_definition_name = "Private DNS Zone Contributor"
}


resource "azurerm_role_assignment" "aks_network_contributor" {
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
  scope                = module.vnet.resource.id
  role_definition_name = "Network Contributor"
}


module "private_dns_zones" {
  source   = "Azure/avm-res-network-privatednszone/azurerm"
  version  = "0.1.2"
  for_each = { for dns_zone in local.private_dns_zones : dns_zone.domain_name => dns_zone }

  resource_group_name   = try(each.value.resource_group_name, azurerm_resource_group.core.name)
  domain_name           = each.key
  virtual_network_links = try(each.value.virtual_network_links, {})
  a_records             = try(each.value.a_records, {})
  aaaa_records          = try(each.value.aaaa_records, {})
  cname_records         = try(each.value.cname_records, {})
  mx_records            = try(each.value.mx_records, {})
  ptr_records           = try(each.value.ptr_records, {})
  srv_records           = try(each.value.srv_records, {})
  txt_records           = try(each.value.txt_records, {})

  tags = local.default_tags
}

output "name" {
  description = "The resource name of the subnet."
  value       = module.vnet.subnets["snet-gw-01"].resource.body.properties.addressPrefixes[0]
  
}