terraform {
  required_version = ">= 1.0.0, < 2.0.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.7.0, < 4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.54.0, < 5.0"
    }
  }
}

