variable "name_prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "account_replication_type" {
  type    = string
  default = "LRS"
}

variable "administrator_login" {
  type = string
}

variable "administrator_login_password" {
  type = string
}

variable "azuread_administrator_username" {
  type    = string
  default = "sqladmin"
}

variable "azuread_administrator_object_id" {
  type    = string
  default = ""
}

variable "enable_azuread_administrator" {
  type    = bool
  default = false
}

variable "azuread_tenant_id" {
  type    = string
  default = ""
}

variable "collation" {
  type    = string
  default = "SQL_Latin1_General_CP1_CI_AS"
}

variable "license_type" {
  type    = string
  default = "LicenseIncluded"
}

variable "storage_size_in_gb" {
  type    = string
  default = "32"
}

variable "sku_name" {
  type    = string
  default = "GP_Gen5"
}

variable "storage_account_type" {
  type    = string
  default = "LRS"
}

variable "subnet_id" {
  type = string
}

variable "vcores" {
  type    = number
  default = 4
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "public_data_endpoint_enabled" {
  type    = bool
  default = false
}

variable "db_name" {
  default = ""
}

variable "instance_name" {
  default = ""
}