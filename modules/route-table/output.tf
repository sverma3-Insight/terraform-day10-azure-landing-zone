output "route_table_ids" { value = { for key, value in azurerm_route_table.route_table : key => value.id } }
