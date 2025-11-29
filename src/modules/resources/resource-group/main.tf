# Crée le resource group seulement s'il n'existe pas
resource "azurerm_resource_group" "this" {
  count    = try(data.azurerm_resource_group.existing.id, null) == null ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}