locals {
  default_app_settings = {
    AppSettings__InstrumentKey                 = azurerm_application_insights.this.instrumentation_key
    APPLICATION_INSIGHTS_IKEY                  = azurerm_application_insights.this.instrumentation_key
    APPINSIGHTS_INSTRUMENTATIONKEY             = azurerm_application_insights.this.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING      = azurerm_application_insights.this.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
  }
}

resource "azurerm_service_plan" "this" {
  name                = var.name != "" ? "serviceplan-${var.name}" : "${var.prefix}-service-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.os_type
  sku_name            = var.sku_name
  tags                = var.tags
}

resource "azurerm_windows_web_app" "this" {
  name                      = var.name != "" ? "app-${var.name}" : "${var.prefix}-win-web-app"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  service_plan_id           = azurerm_service_plan.this.id
  app_settings              = merge(local.default_app_settings, var.app_settings)
  https_only                = true
  virtual_network_subnet_id = var.subnet_id

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true
    application_logs {
      file_system_level = "Error"
    }
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }
  dynamic "site_config" {
    for_each = [var.site_config]
    content {
      always_on                                     = lookup(site_config.value, "always_on", true)
      app_command_line                              = lookup(site_config.value, "app_command_line", null)
      auto_heal_enabled                             = lookup(site_config.value, "auto_heal_enabled", null)
      container_registry_managed_identity_client_id = lookup(site_config.value, "container_registry_managed_identity_client_id", null)
      container_registry_use_managed_identity       = lookup(site_config.value, "container_registry_use_managed_identity", true)
      default_documents                             = lookup(site_config.value, "default_documents", null)
      ftps_state                                    = lookup(site_config.value, "ftps_state", "Disabled")
      health_check_path                             = lookup(site_config.value, "health_check_path", null)
      health_check_eviction_time_in_min             = lookup(site_config.value, "health_check_eviction_time_in_min", null)
      http2_enabled                                 = lookup(site_config.value, "http2_enabled", true)
      # ip_restriction                                = lookup(site_config.value, "ip_restriction", null)
      load_balancing_mode   = lookup(site_config.value, "load_balancing_mode", null)
      local_mysql_enabled   = lookup(site_config.value, "local_mysql_enabled", null)
      managed_pipeline_mode = lookup(site_config.value, "managed_pipeline_mode", null)
      minimum_tls_version   = lookup(site_config.value, "minimum_tls_version", "1.2")
      # scm_ip_restriction                            = lookup(site_config.value, "scm_ip_restriction", null)
      scm_minimum_tls_version     = lookup(site_config.value, "scm_minimum_tls_version", null)
      scm_use_main_ip_restriction = lookup(site_config.value, "scm_use_main_ip_restriction", null)
      use_32_bit_worker           = lookup(site_config.value, "use_32_bit_worker", false)
      websockets_enabled          = lookup(site_config.value, "websockets_enabled", null)
      worker_count                = lookup(site_config.value, "worker_count", null)
      vnet_route_all_enabled      = false
      application_stack {
        dotnet_version = lookup(site_config.value, "dotnet_version", null)
        current_stack  = lookup(site_config.value, "current_stack", null)
      }
      dynamic "ip_restriction" {
        for_each = lookup(site_config.value, "ip_restriction", [])
        content {
          action                    = ip_restriction.value.action
          headers                   = ip_restriction.value.headers
          ip_address                = ip_restriction.value.ip_address
          name                      = ip_restriction.value.name
          priority                  = ip_restriction.value.priority
          service_tag               = ip_restriction.value.service_tag
          virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
        }
      }
    }
  }

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  key_vault_reference_identity_id = azurerm_user_assigned_identity.this.id

  tags = var.tags
}

resource "azurerm_role_assignment" "appservice_to_acr" {
  count                            = var.enable_acr ? 1 : 0
  principal_id                     = azurerm_windows_web_app.this.identity[0].principal_id
  role_definition_name             = "AcrPull"
  scope                            = var.azurerm_container_registry_id
  skip_service_principal_aad_check = true
}

# resource "azurerm_app_service_virtual_network_swift_connection" "this" {
#   count          = var.enable_subnet ? 1 : 0
#   app_service_id = azurerm_windows_web_app.this.id
#   subnet_id      = var.subnet_id
# }

resource "azurerm_application_insights" "this" {
  name                = "${var.prefix}-app-insights"
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = "web"
  workspace_id        = var.workspace_id
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "this" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name = "id-${var.prefix}-${var.location}-001"
  tags = var.tags
}

data "azurerm_dns_zone" "this" {
  count               = var.enable_custom_domain ? 1 : 0
  name                = var.dns_zone_name
  resource_group_name = var.dns_zone_rg_name
}

resource "azurerm_dns_cname_record" "this" {
  count               = var.enable_custom_domain ? 1 : 0
  name                = var.cname_record
  zone_name           = data.azurerm_dns_zone.this[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  record              = azurerm_windows_web_app.this.default_hostname
  tags                = var.tags
}

resource "azurerm_dns_txt_record" "this" {
  count               = var.enable_custom_domain ? 1 : 0
  name                = "asuid.${azurerm_dns_cname_record.this[0].name}"
  zone_name           = data.azurerm_dns_zone.this[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  record {
    value = azurerm_windows_web_app.this.custom_domain_verification_id
  }
  tags = var.tags
}

resource "azurerm_app_service_custom_hostname_binding" "this" {
  count               = var.enable_custom_domain ? 1 : 0
  hostname            = trim(azurerm_dns_cname_record.this[0].fqdn, ".")
  app_service_name    = azurerm_windows_web_app.this.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_dns_txt_record.this[0]]

  # Ignore ssl_state and thumbprint as they are managed using
  # azurerm_app_service_certificate_binding.this
  lifecycle {
    ignore_changes = [ssl_state, thumbprint]
  }
}

resource "azurerm_app_service_managed_certificate" "this" {
  count                      = var.enable_custom_domain ? 1 : 0
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.this[0].id
}

resource "azurerm_app_service_certificate_binding" "this" {
  count               = var.enable_custom_domain ? 1 : 0
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.this[0].id
  certificate_id      = azurerm_app_service_managed_certificate.this[0].id
  ssl_state           = "SniEnabled"
}

resource "azurerm_role_assignment" "this" {
  count                = var.enable_custom_domain ? 1 : 0
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}