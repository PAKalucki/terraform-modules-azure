resource "azurerm_kubernetes_cluster" "this" {
  name                            = var.cluster_name != "" ? var.cluster_name : "${var.prefix}-cluster"
  kubernetes_version              = var.kubernetes_version
  location                        = var.location
  resource_group_name             = var.resource_group_name
  dns_prefix                      = var.dns_prefix
  sku_tier                        = var.sku_tier
  private_cluster_enabled         = var.private_cluster_enabled
  public_network_access_enabled   = var.public_network_access_enabled
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
  automatic_channel_upgrade       = var.automatic_channel_upgrade
  private_dns_zone_id             = var.private_dns_zone_id

  maintenance_window {
    allowed {
      day   = "Saturday"
      hours = [1, 4]
    }
  }

  default_node_pool {
    orchestrator_version   = var.kubernetes_version
    name                   = "systempool"
    vm_size                = var.default_node_pool.agents_size
    os_disk_size_gb        = var.default_node_pool.os_disk_size_gb
    vnet_subnet_id         = var.default_node_pool.vnet_subnet_id
    enable_auto_scaling    = var.default_node_pool.enable_auto_scaling
    max_count              = var.default_node_pool.agents_max_count
    min_count              = var.default_node_pool.agents_min_count
    enable_node_public_ip  = var.default_node_pool.enable_node_public_ip
    zones                  = var.default_node_pool.zones
    type                   = var.default_node_pool.agents_type
    max_pods               = var.default_node_pool.agents_max_pods
    enable_host_encryption = var.default_node_pool.enable_host_encryption
    node_labels            = var.default_node_pool.node_labels
    tags                   = var.tags
  }

  identity {
    type = "SystemAssigned"
  }

  http_application_routing_enabled = var.enable_http_application_routing
  azure_policy_enabled             = var.enable_azure_policy


  dynamic "oms_agent" {
    for_each = var.enable_oms ? [1] : []
    content {
      log_analytics_workspace_id = var.workspace_resource_id
    }
  }

  dynamic "ingress_application_gateway" {
    for_each = var.ingress_application_gateway
    content {
      gateway_id   = lookup(ingress_application_gateway.value, "gateway_id", null)
      gateway_name = lookup(ingress_application_gateway.value, "gateway_name", null)
      subnet_cidr  = lookup(ingress_application_gateway.value, "subnet_cidr", null)
      subnet_id    = lookup(ingress_application_gateway.value, "subnet_id", null)
    }
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = var.secret_rotation_enabled
    secret_rotation_interval = var.secret_rotation_interval
  }

  azure_active_directory_role_based_access_control {
    managed                = var.enable_role_based_access_control
    admin_group_object_ids = var.rbac_aad_admin_group_object_ids
    azure_rbac_enabled     = var.azure_rbac_enabled
  }

  network_profile {
    network_plugin = var.network_profile.network_plugin
    network_policy = var.network_profile.network_policy
  }

  workload_identity_enabled = var.workload_identity_enabled
  oidc_issuer_enabled       = var.workload_identity_enabled

  tags = var.tags

  lifecycle {
    ignore_changes = [
      kubernetes_version,
      default_node_pool["orchestrator_version"]
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each              = var.node_pools
  name                  = substr(each.key, 0, 6)
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  orchestrator_version  = var.kubernetes_version
  vm_size               = each.value.vm_size
  os_type               = each.value.os_type
  os_sku                = each.value.os_sku
  os_disk_size_gb       = each.value.os_disk_size_gb
  os_disk_type          = each.value.os_disk_type
  enable_auto_scaling   = true
  max_count             = each.value.max_count
  min_count             = each.value.min_count
  vnet_subnet_id        = each.value.vnet_subnet_id
  node_labels           = each.value.node_labels
  max_pods              = each.value.max_pods
  priority              = each.value.priority
  eviction_policy       = each.value.eviction_policy
  spot_max_price        = each.value.spot_max_price
  # availability_zones    = each.value.availability_zones

  tags = var.tags

  lifecycle {
    ignore_changes = [
      orchestrator_version,
      
    ]
  }
}

resource "azurerm_role_assignment" "network_contributor" {
  principal_id                     = azurerm_kubernetes_cluster.this.identity[0].principal_id
  role_definition_name             = "Network Contributor"
  scope                            = data.azurerm_resource_group.this.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "metric_publisher" {
  count                            = var.enable_oms ? 1 : 0
  principal_id                     = azurerm_kubernetes_cluster.this.oms_agent[0].oms_agent_identity[0].object_id
  role_definition_name             = "Monitoring Metrics Publisher"
  scope                            = data.azurerm_resource_group.this.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "identity_operator" {
  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  role_definition_name             = "Managed Identity Operator"
  scope                            = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_kubernetes_cluster.this.node_resource_group}"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "vm_contributor" {
  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  role_definition_name             = "Virtual Machine Contributor"
  scope                            = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_kubernetes_cluster.this.node_resource_group}"
  skip_service_principal_aad_check = true
}

data "azurerm_monitor_diagnostic_categories" "this" {
  count       = var.enable_diagnostics ? 1 : 0
  resource_id = azurerm_kubernetes_cluster.this.id
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${var.prefix}-aks-diagnostic"
  target_resource_id         = azurerm_kubernetes_cluster.this.id
  log_analytics_workspace_id = var.workspace_resource_id

  dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.this[0].logs
    content {
      category = log.key
      enabled  = true
      retention_policy {
        enabled = true
        days    = 7
      }
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 7
    }
  }
}