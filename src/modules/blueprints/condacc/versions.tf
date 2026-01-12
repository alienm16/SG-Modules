terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.5.0, < 4.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.53.0"
    }
  }
  required_version = ">= 1.0.0, < 2.0.0"
}
