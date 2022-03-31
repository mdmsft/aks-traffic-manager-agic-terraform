terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "mdmsft"
    storage_account_name = "mdmsft"
    container_name       = "tfstate"
    key                  = "contoso"
  }
}

locals {
  resource_suffix = "${var.project}-${var.environment}-${var.location}"
  context_name    = "${var.project}-${var.environment}"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

data "azurerm_client_config" "main" {}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_suffix}"
  location = var.location
  tags = {
    project     = var.project
    environment = var.environment
    location    = var.location
  }
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${local.resource_suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "null_resource" "azure_cli" {
  provisioner "local-exec" {
    command = "az aks get-credentials -n ${azurerm_kubernetes_cluster.main.name} -g ${azurerm_resource_group.main.name} --context ${local.resource_suffix} --overwrite-existing && kubelogin convert-kubeconfig -l azurecli"
  }
}
