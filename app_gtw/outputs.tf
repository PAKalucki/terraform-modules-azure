output "public_ip" {
  value = azurerm_public_ip.this.ip_address
}

output "public_ip_id" {
  value = azurerm_public_ip.this.id
}

output "user_assigned_identity_client_id" {
  value = azurerm_user_assigned_identity.this.client_id
}

output "user_assigned_identity_principal_id" {
  value = azurerm_user_assigned_identity.this.principal_id
}