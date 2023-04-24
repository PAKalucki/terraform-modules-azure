terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_storage_account" "this" {
  name                     = "${var.prefix}funstorage"
  resource_group_name      = data.azurerm_resource_group.this.name
  location                 = data.azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

resource "azurerm_service_plan" "this" {
  name                = "${var.prefix}-fun-service-plan"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  os_type             = var.os_type
  sku_name            = var.sku_name # premium plan is needed for vnet integration
  tags                = var.tags
}

resource "azurerm_user_assigned_identity" "this" {
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location

  name = "${var.prefix}-fun-identity"
  tags = var.tags
}

resource "azurerm_linux_function_app" "this" {
  name                = "${var.prefix}-fun-app"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location

  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
  # storage_uses_managed_identity = true # this just doesnt work no matter what
  service_plan_id = azurerm_service_plan.this.id

  auth_settings {
    enabled = false
  }

  app_settings = var.app_settings

  dynamic "site_config" {
    for_each = [var.site_config]
    content {
      always_on                         = lookup(site_config.value, "always_on", null) ### https://github.com/hashicorp/terraform-provider-azurerm/issues/10858
      app_command_line                  = lookup(site_config.value, "app_command_line", null)
      default_documents                 = lookup(site_config.value, "default_documents", null)
      ftps_state                        = lookup(site_config.value, "ftps_state", "Disabled")
      health_check_path                 = lookup(site_config.value, "health_check_path", null)
      health_check_eviction_time_in_min = lookup(site_config.value, "health_check_eviction_time_in_min", null)
      http2_enabled                     = lookup(site_config.value, "http2_enabled", true)
      # ip_restriction                    = lookup(site_config.value, "ip_restriction", null)
      load_balancing_mode   = lookup(site_config.value, "load_balancing_mode", null)
      managed_pipeline_mode = lookup(site_config.value, "managed_pipeline_mode", null)
      minimum_tls_version   = lookup(site_config.value, "minimum_tls_version", "1.2")
      # scm_ip_restriction                = lookup(site_config.value, "scm_ip_restriction", null)
      scm_minimum_tls_version     = lookup(site_config.value, "scm_minimum_tls_version", null)
      scm_use_main_ip_restriction = lookup(site_config.value, "scm_use_main_ip_restriction", null)
      use_32_bit_worker           = lookup(site_config.value, "use_32_bit_worker", false)
      websockets_enabled          = lookup(site_config.value, "websockets_enabled", null)
      worker_count                = lookup(site_config.value, "worker_count", null)
      vnet_route_all_enabled      = lookup(site_config.value, "vnet_route_all_enabled", false)
      elastic_instance_minimum    = lookup(site_config.value, "elastic_instance_minimum", null)
      # cors                                   = lookup(site_config.value, "cors", null)
      api_definition_url                     = lookup(site_config.value, "api_definition_url", null)
      api_management_api_id                  = lookup(site_config.value, "api_management_api_id", null)
      app_scale_limit                        = lookup(site_config.value, "app_scale_limit", null)
      application_insights_connection_string = lookup(site_config.value, "application_insights_connection_string", azurerm_application_insights.this.connection_string)
      application_insights_key               = lookup(site_config.value, "application_insights_key", azurerm_application_insights.this.instrumentation_key)

      application_stack {
        dotnet_version              = lookup(site_config.value, "dotnet_version", null)
        python_version              = lookup(site_config.value, "python_version", null)
        use_dotnet_isolated_runtime = lookup(site_config.value, "use_dotnet_isolated_runtime", null)
      }
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  lifecycle {
    ignore_changes = [
      app_settings,
      auth_settings ### provider bug
    ]
  }
  tags = var.tags
}

resource "azurerm_application_insights" "this" {
  name                = "${var.prefix}-function-insights"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  application_type    = "web"
  workspace_id        = var.workspace_id
  tags                = var.tags
}