resource "azurerm_resource_group" "hub" {
  name     = module.naming.resource_group.name
  location = var.location

  tags = local.default_tags
}


module "hub-vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.4.0"

  address_space       = ["10.100.0.0/23"]
  location            = var.location
  name                = "vnet-hub"
  resource_group_name = azurerm_resource_group.hub.name
  subnets = {
    "AzureFirewallSubnet" = {
      name             = "AzureFirewallSubnet"
      address_prefixes = ["10.100.0.0/26"]
    },
    "AzureFirewallManagementSubnet" = {
      name             = "AzureFirewallManagementSubnet"
      address_prefixes = ["10.100.0.64/26"]
    }
  }


  # peerings = {
  #   peertovnet1 = {
  #     name                               = "hub-to-spoke"
  #     #remote_virtual_network_resource_id = data.terraform_remote_state.ms-dev.outputs.core-vnet-id
  #     allow_forwarded_traffic            = true
  #     allow_gateway_transit              = true
  #     allow_virtual_network_access       = true
  #     peer_complete_vnets                = true
  #     #     local_peered_address_spaces = [
  #     #       {
  #     #         address_prefix = "10.6.1.0/24"
  #     #       },
  #     #       {
  #     #         address_prefix = "10.6.2.0/24"
  #     #       }
  #     #     ]
  #     #     remote_peered_address_spaces = [
  #     #       {
  #     #         address_prefix = "10.4.1.0/24"
  #     #       },
  #     #       {
  #     #         address_prefix = "10.4.2.0/24"
  #     #       }
  #     #    ]

  #     create_reverse_peering               = true
  #     reverse_name                         = "spoke-to-hub"
  #     reverse_allow_forwarded_traffic      = false
  #     reverse_allow_gateway_transit        = false
  #     reverse_allow_virtual_network_access = true
  #     reverse_peer_complete_vnets          = true
  #     #   reverse_local_peered_address_spaces = [
  #     #     {
  #     #       address_prefix = "10.4.1.0/24"
  #     #     },
  #     #     {
  #     #       address_prefix = "10.4.2.0/24"
  #     #     }
  #     #   ]
  #     #   reverse_remote_peered_address_spaces = [
  #     #     {
  #     #       address_prefix = "10.6.1.0/24"
  #     #     },
  #     #     {
  #     #       address_prefix = "10.6.2.0/24"
  #     #     }
  #     #   ]
  #   }
  # }

  tags = local.default_tags
}

module "firewall_pips" {
  source   = "Azure/avm-res-network-publicipaddress/azurerm"
  version  = "0.1.2"
  for_each = { for i, pip in local.firewall_pips : i => pip }

  location            = azurerm_resource_group.hub.location
  name                = each.value.name
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = try(each.value.sku, "Standard")
  domain_name_label   = try(each.value.domain_name_label, null)

  tags = local.default_tags
}

# output "values" {
#   value = module.firewall_pips
# }

# # output "name" {
# #   value = module.avm-res-network-hub-virtualnetwork

# # }

module "firewall" {
  source  = "Azure/avm-res-network-azurefirewall/azurerm"
  version = "0.2.2"

  name                = module.naming.firewall.name_unique
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  firewall_sku_tier   = "Standard"
  firewall_sku_name   = "AZFW_VNet"
  # firewall_zones      = ["1", "2", "3"]
  firewall_zones = []
  # DNS Proxy should be added to module
  # dns_servers = []
  # dns_proxy_enabled = true
  firewall_ip_configuration = [
    {
      name                 = "inbound"
      subnet_id            = module.hub-vnet.subnets["AzureFirewallSubnet"].resource.id
      public_ip_address_id = module.firewall_pips[0].public_ip_id
    },
    # {
    #   name                 = "ipconfig2"
    #   public_ip_address_id = azurerm_public_ip.pip[1].id
    # }
  ]
  tags = local.default_tags
}

module "route" {
  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "0.2.2"

  name                = module.naming.route_table.name_unique
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location

  routes = {
    fwrn-01 = {
      name                   = "fwrn-01"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.100.0.4"
    },
    fwinternet-02 = {
      name           = "fwinternet-02"
      address_prefix = "4.174.160.186/32"
      next_hop_type  = "Internet"
    },
    # appgateway-to-aks = {
    #   name           = "appgateway-to-aks"
    #   address_prefix = "4.174.170.190/32"
    #   next_hop_type  = "VirtualNetwork"
    # },
    # gw-traffic-03 = {
    #   name           = "gw-traffic-03"
    #   address_prefix = "Virtual network"
    #   next_hop_type  = "Internet"
    # }

  }

  # subnet_resource_ids = {
  #   subnet1 = "/subscriptions/7f5cc8f5-7f30-436f-96b5-1bf4332c6a2b/resourceGroups/rg-al-dia-canadacentral-dev/providers/Microsoft.Network/virtualNetworks/vnet-al-dia-canadacentral-dev/subnets/snet-aks-nodepool-01",
  #   subnet2 = "/subscriptions/7f5cc8f5-7f30-436f-96b5-1bf4332c6a2b/resourceGroups/rg-al-dia-canadacentral-dev/providers/Microsoft.Network/virtualNetworks/vnet-al-dia-canadacentral-dev/subnets/snet-aks-nodepool-pods-01"
  # }

  # lock = {
  #   kind = "CanNotDelete"
  #   name = "Example-Lock"
  # }
}
# az network route-table route create --resource-group myResourceGroup --route-table-name myRouteTable --name route-to-appgw --address-prefix 4.174.160.186/32 --next-hop-type Internet
# az network route-table route create --resource-group myResourceGroup --route-table-name myRouteTable --name route-to-firewall --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address 10.100.0.4



# module "firewall_policy" {
#   source             = "Azure/avm-res-network-firewallpolicy/azurerm"
#   version = "0.2.2"

#   name                = module.general-naming.firewall_policy.name_unique
#   location            = azurerm_resource_group.hub
#   resource_group_name = azurerm_resource_group.hub.name
# }
# # Update the properties of a VM to change the primary NIC
# az vm update --resource-group MyResourceGroup --name MyVM --nics newPrimaryNICId
# az network firewall nat-rule create --collection-name exampleset --destination-addresses "4.174.160.186" --destination-ports 80 --firewall-name "fw-hub-vnet-al-dia-canadacentral-izzv" --name inboundrule --protocols Any --resource-group rg-hub-vnet-al-dia-canadacentral --source-addresses '*' --translated-port 80 --action Dnat --priority 100 --translated-address 4.174.170.190


# PREFIX="aks-egress"
# RG="${PREFIX}-rg"
# LOC="eastus"
# PLUGIN=azure
# AKSNAME="${PREFIX}"
# VNET_NAME="${PREFIX}-vnet"
# AKSSUBNET_NAME="aks-subnet"
# # DO NOT CHANGE FWSUBNET_NAME - This is currently a requirement for Azure Firewall.
# FWSUBNET_NAME="AzureFirewallSubnet"
# FWNAME="${PREFIX}-fw"
# FWPUBLICIP_NAME="${PREFIX}-fwpublicip"
# FWIPCONFIG_NAME="${PREFIX}-fwconfig"
# FWROUTE_TABLE_NAME="${PREFIX}-fwrt"
# FWROUTE_NAME="${PREFIX}-fwrn"
# FWROUTE_NAME_INTERNET="${PREFIX}-fwinternet"
# RG="rg-hub-vnet-al-dia-canadacentral"
# FWNAME="fw-hub-vnet-al-dia-canadacentral-izzv"
# LOC="canadacentral"
# az network firewall network-rule create --resource-group $RG --firewall-name $FWNAME --collection-name 'aksfwnr' --name 'apiudp' --protocols 'UDP' --source-addresses '*' --destination-addresses "AzureCloud.$LOC" --destination-ports 1194 --action allow --priority 100
# az network firewall network-rule create --resource-group $RG --firewall-name $FWNAME --collection-name 'aksfwnr' --name 'apitcp' --protocols 'TCP' --source-addresses '*' --destination-addresses "AzureCloud.$LOC" --destination-ports 9000
# az network firewall network-rule create --resource-group $RG --firewall-name $FWNAME --collection-name 'aksfwnr' --name 'time' --protocols 'UDP' --source-addresses '*' --destination-fqdns 'ntp.ubuntu.com' --destination-ports 123
# az network firewall network-rule create --resource-group $RG --firewall-name $FWNAME --collection-name 'aksfwnr' --name 'ghcr' --protocols 'TCP' --source-addresses '*' --destination-fqdns ghcr.io pkg-containers.githubusercontent.com --destination-ports '443'
# az network firewall network-rule create --resource-group $RG --firewall-name $FWNAME --collection-name 'aksfwnr' --name 'docker' --protocols 'TCP' --source-addresses '*' --destination-fqdns docker.io registry-1.docker.io production.cloudflare.docker.com --destination-ports '443'
# az network firewall application-rule create --resource-group $RG --firewall-name $FWNAME --collection-name 'aksfwar' --name 'fqdn' --source-addresses '*' --protocols 'http=80' 'https=443' --fqdn-tags "AzureKubernetesService" --action allow --priority 100


# az network firewall nat-rule create --collection-name nat \
# --destination-addresses $FWPUBLIC_IP --destination-ports 80 \
# --firewall-name $FWNAME --name inboundrule --protocols Any --resource-group $RG --source-addresses '*' \
# --translated-port 80 --action Dnat --priority 100 --translated-address "4.174.170.190"