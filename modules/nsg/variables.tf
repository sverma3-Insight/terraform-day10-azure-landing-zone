variable "environment" {}
variable "location" {}
variable "resource_group_name" {}
variable "subnet_ids" { type = map(string) }
variable "nsg_rules" {
  type = map(object({
    name = string, priority = number, direction = string, access = string,
    protocol = string, source_port_range = string, destination_port_range = string,
    source_address_prefix = string, destination_address_prefix = string
  }))
}
variable "tags" { type = map(string) }
