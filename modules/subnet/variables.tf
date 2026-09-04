variable "resource_group_name" {}
variable "virtual_network_name" {}
variable "subnets_var" {
  type = map(object({ name = string, address_prefixes = list(string) }))
}
