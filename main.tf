terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.51.0"
    }

    github = {
      source  = "integrations/github"
      version = "5.21.1"
    }
  }
  backend "azurerm" {
    resource_group_name  = "gokmus-dev"
    storage_account_name = "storagegokmus"
    container_name       = "tetris-githubaction-backend"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {
  }
}
provider "github" {

}

resource "azurerm_resource_group" "rg1" {
  name     = var.rg_name
  location = var.location
}
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = true

}
resource "azurerm_service_plan" "asp" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
}

resource "azurerm_linux_web_app" "app1" {
  name                = var.web_app_name
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {}
}
resource "github_actions_secret" "acr_password" {
  repository      = var.github_repo_name
  secret_name     = "ACR_PASSWORD"
  plaintext_value = azurerm_container_registry.acr.admin_password
}
resource "github_actions_variable" "webapp_name" {
  repository    = var.github_repo_name
  variable_name = "WEBAPP"
  value         = azurerm_linux_web_app.app1.name
}
resource "github_actions_variable" "rg_name" {
  repository    = var.github_repo_name
  variable_name = "RESOURCEGROUP"
  value         = azurerm_resource_group.rg1.name
}