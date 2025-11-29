resource "azurerm_resource_group" "this" {
  count    = var.use_existing ? 0 : 1
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}