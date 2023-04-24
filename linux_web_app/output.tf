output "hostname" {
  value = azurerm_linux_web_app.this.default_hostname
}

output "user_assigned_identity_id" {
  value = azurerm_user_assigned_identity.this.principal_id
}