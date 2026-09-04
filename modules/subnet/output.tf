output "subnet_ids" { value = { for key, value in azurerm_subnet.subnets : key => value.id } }
