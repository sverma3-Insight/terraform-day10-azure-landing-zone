variable "environment" {}
variable "location" {}
variable "resource_group_name" {}
variable "subnet_ids" { type = map(string) }
variable "tags" { type = map(string) }
