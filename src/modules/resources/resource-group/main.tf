resource "azurerm_resource_group" "this" {
  count    = var.use_existing ? 0 : 1
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Importe et gère un resource group existant (avec possibilité de gérer les tags)
resource "azurerm_resource_group" "managed_existing" {
  count    = var.use_existing && var.manage_tags ? 1 : 0
  name     = var.resource_group_name
  location = data.azurerm_resource_group.existing[0].location
  tags     = merge(data.azurerm_resource_group.existing[0].tags, var.tags)

  lifecycle {
    # Empêche la recréation si le RG existe déjà
    prevent_destroy = false
  }
}