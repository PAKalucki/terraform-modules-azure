# data "azurerm_public_ip" "this" {
#   name                = reverse(split("/", tolist(azurerm_kubernetes_cluster.this.network_profile.0.load_balancer_profile.0.effective_outbound_ips)[0]))[0]
#   resource_group_name = var.resource_group_name
# }
data "azurerm_subscription" "current" {}
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}