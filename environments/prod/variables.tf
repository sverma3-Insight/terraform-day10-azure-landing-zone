variable "client_id" { sensitive = true }
variable "client_secret" { sensitive = true }
variable "subscription_id" { sensitive = true }
variable "tenant_id" { sensitive = true }
variable "location" {
  type = string
  validation {
    condition     = contains(["Central India", "South India", "West India"], var.location)
    error_message = "Choose Central India, South India or West India."
  }
}
variable "nsg_rules" {
  type = map(object({
    name = string, priority = number, direction = string, access = string,
    protocol = string, source_port_range = string, destination_port_range = string,
    source_address_prefix = string, destination_address_prefix = string
  }))
}

variable "prod_subnets_var" {
  type = map(object({ name = string, address_prefixes = list(string) }))
}
