locals {
  backend_address_pool_name      = "default"
  frontend_port_name             = "default"
  frontend_ip_configuration_name = "default"
  backend_http_setting_name      = "default"
  gateway_ip_configuration_name  = "default"
  listener_name                  = "default"
  request_routing_rule_name      = "default"
  ssl_certificate_name           = var.project
}

locals {
  key_vault_secret_name = reverse(split("/", azurerm_key_vault_certificate.main.versionless_secret_id))[0]
}

resource "azurerm_public_ip" "gateway" {
  name                = "pip-${local.resource_suffix}-agw"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${var.project}-${var.environment}"
}

resource "azurerm_user_assigned_identity" "agw" {
  name                = "id-${local.resource_suffix}-agw"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
}

resource "azurerm_role_assignment" "agw_key_vault_secrets_user" {
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.agw.principal_id
  scope                = "/subscriptions/${data.azurerm_client_config.main.subscription_id}/resourceGroups/${azurerm_resource_group.main.name}/providers/Microsoft.KeyVault/vaults/${azurerm_key_vault.main.name}/secrets/${local.key_vault_secret_name}"
}

resource "azurerm_web_application_firewall_policy" "main" {
  name                = "waf-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
    request_body_check          = true
  }
}

resource "azurerm_application_gateway" "main" {
  depends_on = [
    azurerm_role_assignment.agw_key_vault_secrets_user
  ]
  name                = "agw-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  firewall_policy_id  = azurerm_web_application_firewall_policy.main.id

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agw.id]
  }

  autoscale_configuration {
    min_capacity = var.azurerm_application_gateway_autoscale_configuration_min_capacity
    max_capacity = var.azurerm_application_gateway_autoscale_configuration_max_capacity
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.backend_http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.gateway.id
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = azurerm_subnet.agw.id
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_setting_name
  }

  ssl_certificate {
    key_vault_secret_id = azurerm_key_vault_certificate.main.versionless_secret_id
    name                = local.ssl_certificate_name
  }
}
