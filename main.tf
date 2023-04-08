terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.51.0"
    }
  }
}

provider "azurerm" {
  backend "azurerm" {
    resource_group_name  = "gokmus-dev"
    storage_account_name = "storagegokmus"
    container_name       = "tetris-githubaction-backend"
    key                  = "prod.terraform.tfstate"
  }

}
resource "azurerm_resource_group" "rg1" {
  name     = "rg1"
  location = "West Europe"
}
resource "azurerm_container_registry" "acr" {
  name                = "contgokmus"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  sku                 = "Premium"
  admin_enabled       = false

}
resource "azurerm_service_plan" "app_plan" {
  name                = "splangokmus"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "webtetris"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_service_plan.app_plan.location
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {}
}
