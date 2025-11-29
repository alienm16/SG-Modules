locals {
  resource_group = var.use_existing ? data.azurerm_resource_group.existing[0] : azurerm_resource_group.this[0]
}
