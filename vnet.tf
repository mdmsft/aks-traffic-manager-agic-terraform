resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.resource_suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.address_space]
}

resource "azurerm_network_security_group" "agw" {
  name                = "nsg-${local.resource_suffix}-agw"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowInternetIn"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "Internet"
    destination_address_prefix = cidrsubnet(var.address_space, 2, 0)
  }

  security_rule {
    name                       = "AllowGatewayManagerIn"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancerIn"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "aks_default" {
  name                = "nsg-${local.resource_suffix}-aks-default"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_group" "aks_main" {
  name                = "nsg-${local.resource_suffix}-aks-main"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "agw" {
  name                 = "snet-agw"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [cidrsubnet(var.address_space, 2, 0)]
}

resource "azurerm_subnet" "aks_default" {
  name                 = "snet-aks-default"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [cidrsubnet(var.address_space, 2, 1)]
}

resource "azurerm_subnet" "aks_main" {
  name                 = "snet-aks-main"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [cidrsubnet(var.address_space, 2, 2)]
}

resource "azurerm_subnet_network_security_group_association" "agw" {
  network_security_group_id = azurerm_network_security_group.agw.id
  subnet_id                 = azurerm_subnet.agw.id
}

resource "azurerm_subnet_network_security_group_association" "aks_default" {
  network_security_group_id = azurerm_network_security_group.aks_default.id
  subnet_id                 = azurerm_subnet.aks_default.id
}

resource "azurerm_subnet_network_security_group_association" "aks_main" {
  network_security_group_id = azurerm_network_security_group.aks_main.id
  subnet_id                 = azurerm_subnet.aks_main.id
}
