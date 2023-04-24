output "hostname" {
  value = azurerm_windows_web_app.this.default_hostname
}

output "user_assigned_identity_id" {
  value = azurerm_user_assigned_identity.this.principal_id
}