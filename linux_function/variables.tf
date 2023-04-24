variable "resource_group_name" {
  type = string
}

variable "prefix" {
  type = string
}

variable "sku_name" {
  type    = string
  default = "Y1"
}

variable "site_config" {
  type    = any
  default = {}
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "workspace_id" {
  type = string
}

variable "app_settings" {
  type    = map(any)
  default = {}
}

variable "os_type" {
  type    = string
  default = "Linux"
}