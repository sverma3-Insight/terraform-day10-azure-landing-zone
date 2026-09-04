terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 5.0.0" }
  }
  required_version = ">= 1.1.0"
  backend "azurerm" {
    resource_group_name  = "SV"
    storage_account_name = "capestonestorageaccount"
    container_name       = "tfstate-container"
    key                  = "prod.tfstate"
  }
}
provider "azurerm" {
  features {}
  client_id = var.client_id
  client_secret = var.client_secret
  subscription_id = var.subscription_id
  tenant_id = var.tenant_id
}

locals { 
  common_tags = { 
    environment = "prod"
    region = var.location
    managed_by = "terraform" 
    } 
    }

data "azurerm_virtual_network" "hub" { 
  name = "VNET-Day10-Hub"
  resource_group_name = "RG-Day10-Hub" 
  }
module "prod_rg" { 
  source = "../../modules/resource-group"
  resource_group_name = "RG-Day10-PROD"
  location = var.location
  tags = local.common_tags 
  }

module "prod_vnet" { 
  source = "../../modules/vnet"
  vnet_name = "VNET-Day10-PROD"
  location = var.location
  resource_group_name = module.prod_rg.resource_group_name
  address_space = ["10.3.0.0/16"]
  tags = local.common_tags 
  }

module "prod_subnets" {
  source = "../../modules/subnet"
  resource_group_name = module.prod_rg.resource_group_name
  virtual_network_name = module.prod_vnet.vnet_name
  subnets_var = var.prod_subnets_var
}
module "prod_nsg" { 
  source = "../../modules/nsg"
  environment = "prod"
  location = var.location
  resource_group_name = module.prod_rg.resource_group_name
  subnet_ids = module.prod_subnets.subnet_ids
  nsg_rules = var.nsg_rules
  tags = local.common_tags 
  }

module "prod_route_table" { 
  source = "../../modules/route-table"
  environment = "prod"
  location = var.location
  resource_group_name = module.prod_rg.resource_group_name
  subnet_ids = module.prod_subnets.subnet_ids
  tags = local.common_tags 
  }

module "prod_to_hub" { 
  source = "../../modules/vnet-peering"
  peering_name = "prod-to-hub"
  resource_group_name = module.prod_rg.resource_group_name
  virtual_network_name = module.prod_vnet.vnet_name
  remote_virtual_network_id = data.azurerm_virtual_network.hub.id 
  }

module "hub_to_prod" { 
  source = "../../modules/vnet-peering"
  peering_name = "hub-to-prod"
  resource_group_name = data.azurerm_virtual_network.hub.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.hub.name
  remote_virtual_network_id = module.prod_vnet.vnet_id
  allow_gateway_transit = true 
  }
