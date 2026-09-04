resource "azurerm_route_table" "route_table" {
  for_each            = var.subnet_ids
  name                = "${var.environment}-${each.key}-rt"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_route_table_association" "association" {
  for_each       = var.subnet_ids
  subnet_id      = each.value
  route_table_id = azurerm_route_table.route_table[each.key].id
}
