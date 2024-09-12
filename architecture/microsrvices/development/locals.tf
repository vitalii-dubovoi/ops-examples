locals {
  default_tags = {
    environment        = var.environment
    project            = var.project
    logical_enviroment = var.logical_enviroment

  }

  private_dns_zones = [
    {
      domain_name = "privatelink.${var.location}.azmk8s.io"
      virtual_network_links = {
        # vnetlink1 = {
        #   vnetlinkname = "vnetlink1"
        #   vnetid           = data.terraform_remote_state.ms-dev.outputs.core-vnet-id
        #   autoregistration = true
        #   tags = {
        #     "env" = "prod"
        #   }
        # }
      }
    }
  ]
  #   node_pools = { for key, value in local.nodes : value.name => value }
  #   nodes = [
  #     {
  #       name       = "workerks"
  #       vm_size    = "Standard_D2s_v5"
  #       node_count = 1
  #       min_count  = 1
  #       max_count  = 1
  #       #vnet_subnet_id      = module.avm-res-network-virtualnetwork.subnets["${module.general-naming.subnet.slug}-aks-${var.project}-${var.environment}"].resource.id
  #       enable_auto_scaling = true
  #     }
  #   ]
  #   firewall_pips = [
  #     {
  #       name              = "${module.aks-pip.public_ip.name_unique}"
  #       domain_name_label = "argo"
  #     },
  #     # {
  #     #   name              = "${module.aks-pip.public_ip.name_unique}"
  #     #   domain_name_label = "aldia-dev"
  #     # }
  #   ]
}

