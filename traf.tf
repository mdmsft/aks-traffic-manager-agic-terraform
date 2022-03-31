locals {
  name = "${var.project}-${var.environment}"
}

resource "azurerm_traffic_manager_profile" "main" {
  name                   = local.name
  resource_group_name    = azurerm_resource_group.main.name
  traffic_routing_method = "Performance"
  traffic_view_enabled   = true

  dns_config {
    relative_name = local.name
    ttl           = 60
  }

  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/"
    expected_status_code_ranges  = ["200-299"]
    interval_in_seconds          = 10
    timeout_in_seconds           = 5
    tolerated_number_of_failures = 1
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "main" {
  name               = azurerm_public_ip.gateway.fqdn
  profile_id         = azurerm_traffic_manager_profile.main.id
  target_resource_id = azurerm_public_ip.gateway.id
  weight             = 1000
}

resource "azurerm_monitor_diagnostic_setting" "traf" {
  name                       = "default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  target_resource_id         = azurerm_traffic_manager_profile.main.id

  log {
    category = "ProbeHealthStatusEvents"
    enabled  = true
  }
}
