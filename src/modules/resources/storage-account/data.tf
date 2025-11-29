data "azurerm_storage_account" "existing" {
  count               = var.use_existing_storage ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}