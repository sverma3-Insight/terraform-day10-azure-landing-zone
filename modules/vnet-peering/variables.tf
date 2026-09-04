variable "peering_name" {}
variable "resource_group_name" {}
variable "virtual_network_name" {}
variable "remote_virtual_network_id" {}
variable "allow_gateway_transit" {
  type    = bool
  default = false
}

variable "use_remote_gateways" {
  type    = bool
  default = false
}
