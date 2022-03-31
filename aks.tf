locals {
  subnets = [
    azurerm_subnet.aks_default.id,
    azurerm_subnet.aks_main.id
  ]
}

resource "azurerm_kubernetes_cluster" "main" {
  name                              = "aks-${local.resource_suffix}"
  location                          = var.location
  resource_group_name               = azurerm_resource_group.main.name
  dns_prefix                        = local.context_name
  automatic_channel_upgrade         = var.kubernetes_cluster_automatic_channel_upgrade
  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                         = "default"
    vm_size                      = var.kubernetes_cluster_default_node_pool_vm_size
    enable_auto_scaling          = true
    min_count                    = var.kubernetes_cluster_default_node_pool_min_count
    max_count                    = var.kubernetes_cluster_default_node_pool_max_count
    max_pods                     = var.kubernetes_cluster_default_node_pool_max_pods
    os_disk_size_gb              = var.kubernetes_cluster_default_node_pool_os_disk_size_gb
    os_sku                       = var.kubernetes_cluster_default_node_pool_os_sku
    only_critical_addons_enabled = true
    vnet_subnet_id               = azurerm_subnet.aks_default.id
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.main.id
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "main" {
  name                  = "main"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.kubernetes_cluster_main_node_pool_vm_size
  enable_auto_scaling   = true
  min_count             = var.kubernetes_cluster_main_node_pool_min_count
  max_count             = var.kubernetes_cluster_main_node_pool_max_count
  max_pods              = var.kubernetes_cluster_main_node_pool_max_pods
  os_disk_size_gb       = var.kubernetes_cluster_main_node_pool_os_disk_size_gb
  os_sku                = var.kubernetes_cluster_main_node_pool_os_sku
  vnet_subnet_id        = azurerm_subnet.aks_main.id

  upgrade_settings {
    max_surge = "100%"
  }
}

resource "azurerm_role_assignment" "aks_rbac_reader" {
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  scope                = azurerm_kubernetes_cluster.main.id
  principal_id         = data.azurerm_client_config.main.object_id
}

resource "azurerm_role_assignment" "aks_network_contributor" {
  count                = length(local.subnets)
  role_definition_name = "Network Contributor"
  scope                = local.subnets[count.index]
  principal_id         = azurerm_kubernetes_cluster.main.identity.0.principal_id
}

resource "azurerm_role_assignment" "agw" {
  for_each = {
    "Contributor"               = azurerm_application_gateway.main.id
    "Reader"                    = azurerm_resource_group.main.id
    "Managed Identity Operator" = azurerm_user_assigned_identity.agw.id
  }
  scope                = each.value
  role_definition_name = each.key
  principal_id         = azurerm_kubernetes_cluster.main.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}
