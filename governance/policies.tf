terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 5.0.0" }
  }
  required_version = ">= 1.1.0"
  backend "azurerm" {
    resource_group_name  = "SV"
    storage_account_name = "capestonestorageaccount"
    container_name       = "tfstate-container"
    key                  = "governance.tfstate"
  }
}
provider "azurerm" {
  features {}
  client_id = var.client_id
  client_secret = var.client_secret
  subscription_id = var.subscription_id
  tenant_id = var.tenant_id
}

resource "azurerm_subscription_policy_assignment" "allowed_locations" {
  name                 = "day10-allowed-locations"
  display_name         = "Day10 Allowed Locations"
  subscription_id      = "/subscriptions/${var.subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  parameters = jsonencode({ listOfAllowedLocations = { value = var.allowed_locations } })
}

resource "azurerm_subscription_policy_assignment" "allowed_resource_types" {
  name                 = "day10-allowed-resource-types"
  display_name         = "Day10 Allowed Resource Types"
  subscription_id      = "/subscriptions/${var.subscription_id}"

  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/a08ec900-254a-4555-9bf5-e42af04b5c5c"

  parameters = jsonencode({
    listOfResourceTypesAllowed = {
      value = [
        "Microsoft.Network/virtualNetworks",
        "Microsoft.Network/networkSecurityGroups",
        "Microsoft.Network/routeTables",
        "Microsoft.Network/publicIPAddresses",
        "Microsoft.Compute/virtualMachines",
        "Microsoft.Network/azureFirewalls",
        "Microsoft.Network/bastionHosts",
        "Microsoft.Network/virtualNetworkGateways"
      ]
    }
  })
}

resource "azurerm_subscription_policy_assignment" "required_environment_tag" {
  name                 = "day10-required-environment-tag"
  display_name         = "Day10 Require Environment Tag"
  subscription_id      = "/subscriptions/${var.subscription_id}"

  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"

  parameters = jsonencode({
    tagName = {
      value = "environment"
    }
  })
}