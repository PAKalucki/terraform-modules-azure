output "instance_name" {
  value = azurerm_mssql_managed_instance.this.name
}

output "database_name" {
  value = azurerm_mssql_managed_database.this.name
}

output "database_url" {
  value = azurerm_mssql_managed_instance.this.fqdn
}
# output "public_database_url" {
#   value = "${azurerm_mssql_managed_instance.this.name}.public.${local.unique_id}.database.windows.net"
# }