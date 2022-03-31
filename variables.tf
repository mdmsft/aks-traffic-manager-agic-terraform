variable "location" {
  type    = string
  default = "westeurope"
}

variable "project" {
  type    = string
  default = "contoso"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "address_space" {
  type    = string
  default = "172.17.0.0/22"
}

variable "dns_zone_id" {
  type = string
}

variable "kubernetes_cluster_automatic_channel_upgrade" {
  type    = string
  default = "node-image"
}

variable "kubernetes_cluster_default_node_pool_vm_size" {
  type    = string
  default = "Standard_DS2_v2"
}

variable "kubernetes_cluster_default_node_pool_max_pods" {
  type    = number
  default = 30
}

variable "kubernetes_cluster_default_node_pool_min_count" {
  type    = number
  default = 1
}

variable "kubernetes_cluster_default_node_pool_max_count" {
  type    = number
  default = 3
}

variable "kubernetes_cluster_default_node_pool_os_disk_size_gb" {
  type    = number
  default = 30
}

variable "kubernetes_cluster_default_node_pool_os_sku" {
  type    = string
  default = "Ubuntu"
}

variable "kubernetes_cluster_main_node_pool_vm_size" {
  type    = string
  default = "Standard_F4s_v2"
}

variable "kubernetes_cluster_main_node_pool_max_pods" {
  type    = number
  default = 30
}

variable "kubernetes_cluster_main_node_pool_min_count" {
  type    = number
  default = 1
}

variable "kubernetes_cluster_main_node_pool_max_count" {
  type    = number
  default = 3
}

variable "kubernetes_cluster_main_node_pool_os_disk_size_gb" {
  type    = number
  default = 30
}

variable "kubernetes_cluster_main_node_pool_os_sku" {
  type    = string
  default = "Ubuntu"
}

variable "azurerm_application_gateway_autoscale_configuration_min_capacity" {
  type    = number
  default = 1
}

variable "azurerm_application_gateway_autoscale_configuration_max_capacity" {
  type    = number
  default = 3
}

variable "tenants" {
  type    = list(string)
  default = ["tailspin", "wingtip"]
}
