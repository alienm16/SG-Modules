locals {
  storage_account = var.use_existing_storage ? data.azurerm_storage_account.existing[0] : azurerm_storage_account.this[0]
}
