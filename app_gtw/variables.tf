variable "prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "fqdns" {
  type = list(string)
}

variable "host_name" {
  type = string
}

variable "key_vault_secret_id" {
  type = string
}