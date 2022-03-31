resource "azurerm_key_vault" "main" {
  name                      = substr("kv-${local.resource_suffix}-${split("-", data.azurerm_client_config.main.subscription_id)[0]}", 0, 24)
  location                  = var.location
  resource_group_name       = azurerm_resource_group.main.name
  enable_rbac_authorization = true
  sku_name                  = "standard"
  tenant_id                 = data.azurerm_client_config.main.tenant_id
}

resource "azurerm_role_assignment" "key_vault_administrator" {
  role_definition_name = "Key Vault Administrator"
  scope                = azurerm_key_vault.main.id
  principal_id         = data.azurerm_client_config.main.object_id
}

resource "azurerm_key_vault_certificate" "main" {
  name         = var.project
  key_vault_id = azurerm_key_vault.main.id

  certificate {
    contents = filebase64("./certificate.pfx")
  }

  depends_on = [
    azurerm_role_assignment.key_vault_administrator
  ]
}
