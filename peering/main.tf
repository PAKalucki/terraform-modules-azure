terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

resource "azurerm_virtual_network_peering" "peering" {
  name                         = "${var.vnet_1_name}_to_${var.vnet_2_name}"
  resource_group_name          = var.vnet_1_resource_group_name
  virtual_network_name         = var.vnet_1_name
  remote_virtual_network_id    = var.vnet_2_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "peering_back" {
  name                         = "${var.vnet_2_name}_to_${var.vnet_1_name}"
  resource_group_name          = var.vnet_2_resource_group_name
  virtual_network_name         = var.vnet_2_name
  remote_virtual_network_id    = var.vnet_1_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}