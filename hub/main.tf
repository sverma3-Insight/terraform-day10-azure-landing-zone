terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 5.0.0" }
  }
  required_version = ">= 1.1.0"
  backend "azurerm" {
    resource_group_name  = "SV"
    storage_account_name = "capestonestorageaccount"
    container_name       = "tfstate-container"
    key                  = "hub.tfstate"
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
    environment = "shared"
    region = var.location
    managed_by = "terraform" 
    } 
    }
    
module "hub_rg" { 
  source = "../modules/resource-group"
  resource_group_name = "RG-Day10-Hub"
  location = var.location
  tags = local.common_tags 
  }

module "hub_vnet" { 
  source = "../modules/vnet"
  vnet_name = "VNET-Day10-Hub"
  location = var.location
  resource_group_name = module.hub_rg.resource_group_name
  address_space = ["10.0.0.0/16"]
  tags = local.common_tags 
  }

module "hub_subnets" {
  source = "../modules/subnet"
  resource_group_name = module.hub_rg.resource_group_name
  virtual_network_name = module.hub_vnet.vnet_name
  subnets_var = {
    AzureFirewallSubnet = { name = "AzureFirewallSubnet", address_prefixes = ["10.0.0.0/26"] }
    AzureBastionSubnet  = { name = "AzureBastionSubnet", address_prefixes = ["10.0.1.0/26"] }
    GatewaySubnet       = { name = "GatewaySubnet", address_prefixes = ["10.0.2.0/27"] }
    SharedServices      = { name = "SharedServices", address_prefixes = ["10.0.3.0/24"] }
  }
}
resource "azurerm_public_ip" "firewall_pip" { 
  count = var.enable_firewall ? 1 : 0
  name = "PIP-Day10-Firewall"
  location = var.location
  resource_group_name = module.hub_rg.resource_group_name
  allocation_method = "Static"
  sku = "Standard" 
  tags = local.common_tags
  }

resource "azurerm_firewall" "firewall" { 
  count = var.enable_firewall ? 1 : 0
  name = "FW-Day10-Hub"
  location = var.location
  resource_group_name = module.hub_rg.resource_group_name
  sku_name = "AZFW_VNet"
  sku_tier = "Standard"
  tags = local.common_tags
  ip_configuration { 
    name = "firewall-config"
  subnet_id = module.hub_subnets.subnet_ids["AzureFirewallSubnet"]
  public_ip_address_id = azurerm_public_ip.firewall_pip[0].id 
  } 
  }

resource "azurerm_public_ip" "bastion_pip" { 
  count = var.enable_bastion ? 1 : 0
  name = "PIP-Day10-Bastion"
  location = var.location
  resource_group_name = module.hub_rg.resource_group_name
  allocation_method = "Static"
  sku = "Standard" 
  tags = local.common_tags
  }

resource "azurerm_bastion_host" "bastion" { 
  count = var.enable_bastion ? 1 : 0
  name = "Bastion-Day10-Hub"
  location = var.location
  resource_group_name = module.hub_rg.resource_group_name
  tags = local.common_tags
  ip_configuration { 
    name = "bastion-config"
  subnet_id = module.hub_subnets.subnet_ids["AzureBastionSubnet"]
  public_ip_address_id = azurerm_public_ip.bastion_pip[0].id 
  } 
  }

resource "azurerm_public_ip" "vpn_pip" { 
  count = var.enable_vpn_gateway ? 1 : 0
  name = "PIP-Day10-VPN"
  location = var.location
  resource_group_name = module.hub_rg.resource_group_name
  allocation_method = "Static"
  sku = "Standard" 
  zones = ["1", "2", "3"]
  tags = local.common_tags
  }

resource "azurerm_virtual_network_gateway" "vpn_gateway" { 
  count = var.enable_vpn_gateway ? 1 : 0
  name = "VPNGW-Day10-Hub"
  location = var.location
  resource_group_name = module.hub_rg.resource_group_name
  type = "Vpn"
  vpn_type = "RouteBased"
  sku = "VpnGw1AZ"
  tags = local.common_tags
  ip_configuration { 
  name = "vpn-config"
  public_ip_address_id = azurerm_public_ip.vpn_pip[0].id
  private_ip_address_allocation = "Dynamic"
  subnet_id = module.hub_subnets.subnet_ids["GatewaySubnet"] 
  } 
  }
