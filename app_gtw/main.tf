locals {
  frontend_ip_configuration_name = "${var.prefix}-app-gw-frontend"
  gateway_ip_configuration_name  = "${var.prefix}-app-gw-configuration"
  frontend_port_name             = "${var.prefix}-app-gw-frontend-port"
  backend_address_pool_name      = "${var.prefix}-app-gw-backend-pool"
  backend_http_settings_name     = "${var.prefix}-app-gw-b-http-stg"
  http_listener_name             = "${var.prefix}-app-gw-http-listener"
  request_routing_rule_name      = "${var.prefix}-app-gw-routing-rule"
  ssl_profile_name               = "${var.prefix}-app-gw-ssl-profile"
  ssl_certificate_name           = "${var.prefix}-app-gw-ssl-cert"
}
resource "azurerm_application_gateway" "this" {
  name                = "${var.prefix}-app-gw"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 10
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.this.id
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 443
  }

  backend_address_pool {
    name  = local.backend_address_pool_name
    fqdns = var.fqdns
  }

  backend_http_settings {
    name                                = local.backend_http_settings_name
    cookie_based_affinity               = "Disabled"
    path                                = "/"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Https"
    host_name                      = var.host_name
    ssl_certificate_name           = local.ssl_certificate_name
    ssl_profile_name               = local.ssl_profile_name
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.http_listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_settings_name
  }

  ssl_certificate {
    name                = local.ssl_certificate_name
    key_vault_secret_id = var.key_vault_secret_id
  }

  ssl_profile {
    name = local.ssl_profile_name
    ssl_policy {
      policy_name = "AppGwSslPolicy20220101S"
      policy_type = "Predefined"
    }
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  tags = local.tags
}

resource "azurerm_user_assigned_identity" "this" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name = "${local.prefix}-appgw-identity"
  tags = local.tags
}

resource "azurerm_public_ip" "this" {
  name                = "${local.prefix}-app-gw-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = local.tags
}