resource "azurerm_mssql_managed_database" "this" {
  name                = var.db_name != "" ? var.db_name : "${var.name_prefix}-sqldb"
  managed_instance_id = azurerm_mssql_managed_instance.this.id

  timeouts {
    create = "4h"
  }
}

resource "azurerm_mssql_managed_instance" "this" {
  name                         = var.instance_name != "" ? var.instance_name : "${var.name_prefix}-instance"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  collation                    = var.collation
  license_type                 = var.license_type
  sku_name                     = var.sku_name
  storage_size_in_gb           = var.storage_size_in_gb
  subnet_id                    = var.subnet_id
  vcores                       = var.vcores
  storage_account_type         = var.storage_account_type
  public_data_endpoint_enabled = var.public_data_endpoint_enabled

  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password

  identity {
    type = "SystemAssigned"
  }

  timeouts {
    create = "4h"
  }

  tags = var.tags
}

# resource "azuread_directory_role" "this" {
#   count        = var.enable_azuread_administrator ? 1 : 0
#   display_name = "Directory Readers"
# }

# resource "azuread_directory_role_assignment" "this" {
#   count            = var.enable_azuread_administrator ? 1 : 0
#   role_id = azuread_directory_role.this[0].template_id
#   principal_object_id = azurerm_mssql_managed_instance.this.identity.0.principal_id
# }

# resource "azurerm_mssql_managed_instance_active_directory_administrator" "this" {
#   count                       = var.enable_azuread_administrator ? 1 : 0
#   managed_instance_id         = azurerm_mssql_managed_instance.this.id
#   login_username              = var.azuread_administrator_username
#   object_id                   = var.azuread_administrator_object_id
#   tenant_id                   = var.azuread_tenant_id
#   azuread_authentication_only = false
#   depends_on = [
#     azuread_directory_role_assignment.this
#   ]
# }