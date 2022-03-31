locals {
  dns_zone_name                = split("/", var.dns_zone_id)[8]
  dns_zone_resource_group_name = split("/", var.dns_zone_id)[4]
}

data "azurerm_dns_zone" "main" {
  name                = local.dns_zone_name
  resource_group_name = local.dns_zone_resource_group_name
}

resource "azurerm_dns_cname_record" "main" {
  for_each            = toset(var.tenants)
  name                = each.value
  zone_name           = data.azurerm_dns_zone.main.name
  resource_group_name = data.azurerm_dns_zone.main.resource_group_name
  ttl                 = 60
  target_resource_id  = azurerm_traffic_manager_profile.main.id
}
