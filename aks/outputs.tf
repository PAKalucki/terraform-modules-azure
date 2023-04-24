output "host" {
  value     = azurerm_kubernetes_cluster.this.kube_admin_config.0.host
  sensitive = true
}

output "username" {
  value     = azurerm_kubernetes_cluster.this.kube_admin_config.0.username
  sensitive = true
}

output "password" {
  value     = azurerm_kubernetes_cluster.this.kube_admin_config.0.password
  sensitive = true
}

output "client_certificate" {
  value     = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.client_certificate)
  sensitive = true
}

output "client_key" {
  value     = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.client_key)
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = base64decode(azurerm_kubernetes_cluster.this.kube_admin_config.0.cluster_ca_certificate)
  sensitive = true
}

output "kubelet_identity_client_id" {
  value = azurerm_kubernetes_cluster.this.kubelet_identity[0].client_id
}

output "kubelet_identity_object_id" {
  value = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "node_resource_group_name" {
  value = azurerm_kubernetes_cluster.this.node_resource_group
}

output "node_resource_group_location" {
  value = azurerm_kubernetes_cluster.this.location
}

output "principal_id" {
  value = azurerm_kubernetes_cluster.this.identity[0].principal_id
}

output "secret_identity_client_id" {
  value = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].client_id
}

output "secret_identity_object_id" {
  value = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].object_id
}

# output "oms_agent_identity_client_id" {
#   value = azurerm_kubernetes_cluster.this.oms_agent[0].oms_agent_identity[0].client_id
# }

# output "oms_agent_identity_object_id" {
#   value = azurerm_kubernetes_cluster.this.oms_agent[0].oms_agent_identity[0].object_id
# }

output "aks_rg" {
  value = azurerm_kubernetes_cluster.this.node_resource_group
}