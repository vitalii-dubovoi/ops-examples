module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.1"

  suffix = ["${var.project}", "${var.location}", "${var.environment}"]
}


module "subnet" {
  source  = "Azure/naming/azurerm"
  version = "0.4.1"

  suffix = ["aks", "${var.environment}"]
}
