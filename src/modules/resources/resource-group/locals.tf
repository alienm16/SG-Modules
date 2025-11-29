locals {
  # Détermine automatiquement quel RG utiliser
  resource_group = try(data.azurerm_resource_group.existing, azurerm_resource_group.this[0])
}