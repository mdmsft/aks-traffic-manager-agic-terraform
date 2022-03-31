output "hostname" {
  value = data.azurerm_dns_zone.main.name
}

output "tenants" {
  value = [for tenant in var.tenants : tenant]
}

output "ssl_certificate_name" {
  value = local.ssl_certificate_name
}
