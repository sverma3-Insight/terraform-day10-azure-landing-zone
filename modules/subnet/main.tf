resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets_var
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = each.value.address_prefixes
}
