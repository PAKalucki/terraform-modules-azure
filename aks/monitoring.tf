# resource "azurerm_log_analytics_workspace" "this" {
#   count               = var.enable_log_analytics ? 1 : 0
#   name                = "${var.env}-law"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   sku                 = "PerGB2018"

#   tags = var.tags
# }

resource "azurerm_log_analytics_solution" "this" {
  solution_name         = "Containers"
  workspace_resource_id = var.workspace_resource_id #azurerm_log_analytics_workspace.this[0].id
  workspace_name        = var.workspace_name        #azurerm_log_analytics_workspace.this[0].name
  resource_group_name   = var.resource_group_name
  location              = var.location

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Containers"
  }

  tags = var.tags
}