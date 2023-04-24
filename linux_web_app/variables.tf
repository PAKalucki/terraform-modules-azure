variable "prefix" {
  type        = string
  description = "Prefix to be used in naming of resources"
  default     = "webapp"
}

variable "sku_name" {
  type    = string
  default = "B1"
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type    = string
  default = null
}

variable "os_type" {
  type    = string
  default = "Linux"
}

variable "site_config" {
  type    = any
  default = {}
}

variable "app_settings" {
  type    = map(string)
  default = {}
}

variable "azurerm_container_registry_id" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "application_stacks" {
  type = map(string)
  default = {
  }
}

variable "enable_acr" {
  type    = bool
  default = true
}

variable "enable_subnet" {
  type    = bool
  default = true
}

variable "enable_custom_domain" {
  default = false
  type    = bool
}

variable "dns_zone_name" {
  type    = string
  default = null
}

variable "dns_zone_rg_name" {
  type    = string
  default = null
}

variable "cname_record" {
  type    = string
  default = null
}

variable "key_vault_id" {
  type    = string
  default = null
}

variable "workspace_id" {
  type = string
}

variable "enable_availability_test" {
  default = false
  type    = bool
}

variable "enable_diagnostics" {
  type    = bool
  default = false
}

variable "enable_web_test" {
  type    = bool
  default = false
}

variable "name" {
  default = ""
}
