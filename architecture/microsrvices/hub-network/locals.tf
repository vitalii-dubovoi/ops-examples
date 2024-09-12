locals {
  default_tags = {
    environment = var.environment
    project     = var.project
    purpose     = var.purpose
  }

  # private_dns_zones = [
  #   {
  #     domain_name = "privatelink.${var.location}.azmk8s.io"
  #     virtual_network_links = {
  #       vnetlink1 = {
  #         vnetlinkname = "vnetlink1"
  #         # vnetid           = data.terraform_remote_state.ms-dev.outputs.core-vnet-id
  #         autoregistration = true
  #         tags = {
  #           "env" = "prod"
  #         }
  #       }
  #     }
  #   }
  # ]

  firewall_pips = [
    {
      name              = "${module.naming.public_ip.name_unique}"
      domain_name_label = "fw-aldia"
    },
    # {
    #   name              = "${module.aks-pip.public_ip.name_unique}"
    #   domain_name_label = "aldia-dev"
    # }
  ]
}

