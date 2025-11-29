data "azurerm_resource_group" "existing" {
  count = var.use_existing ? 1 : 0
  name  = var.resource_group_name
}