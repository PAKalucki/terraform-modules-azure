variable "prefix" {
  type    = string
  default = "aks"
}

variable "cluster_name" {
  type    = string
  default = ""
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "sku_tier" {
  type    = string
  default = "Free"
}

variable "private_cluster_enabled" {
  type    = bool
  default = false
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "api_server_authorized_ip_ranges" {
  type    = list(string)
  default = []
}

variable "default_node_pool" {
  default = {
    agents_size            = ""
    os_disk_size_gb        = ""
    vnet_subnet_id         = ""
    enable_auto_scaling    = true
    agents_max_count       = 2
    agents_min_count       = 1
    enable_node_public_ip  = false
    zones                  = ["1", "2", "3"]
    agents_type            = ""
    agents_max_pods        = 100
    enable_host_encryption = true
  }
}

variable "enable_http_application_routing" {
  type    = bool
  default = false
}

variable "enable_azure_policy" {
  type    = bool
  default = true
}

variable "enable_role_based_access_control" {
  type    = bool
  default = true
}

# variable "azure_active_directory_managed" {
#   type    = bool
#   default = true
# }

variable "azure_rbac_enabled" {
  type    = bool
  default = true
}

variable "rbac_aad_admin_group_object_ids" {
  type    = list(string)
  default = []
}

variable "network_profile" {
  default = {
    network_plugin                 = ""
    network_policy                 = ""
    net_profile_dns_service_ip     = ""
    net_profile_docker_bridge_cidr = ""
    net_profile_service_cidr       = ""
  }
}

variable "node_pools" {
  type        = map(any)
  default     = {}
  description = "Additional node pools definitions"
}

variable "enable_keyvault_secrets_provider" {
  type    = bool
  default = true
}

variable "secret_rotation_enabled" {
  type    = bool
  default = false
}

variable "secret_rotation_interval" {
  type    = string
  default = "3m"
}

variable "workspace_name" {
  type = string
}

variable "workspace_resource_id" {
  type = string
}

#https://docs.microsoft.com/en-us/azure/aks/upgrade-cluster#set-auto-upgrade-channel
variable "automatic_channel_upgrade" {
  type        = string
  default     = "stable"
  description = "Options: none patch stable rapid node-image"
}

variable "ingress_application_gateway" {
  type    = map(any)
  default = {}
}

variable "tags" {
  type = map(string)
}

variable "private_dns_zone_id" {
  type    = string
  default = null
}

variable "enable_diagnostics" {
  type    = bool
  default = false
}

variable "workload_identity_enabled" {
  default = false
  type    = bool
}

variable "enable_oms" {
  type    = bool
  default = false
}