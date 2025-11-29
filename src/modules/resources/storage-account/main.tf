# Gestion du resource group
module "resource_group" {
  source = "../resource-group"

  resource_group_name = var.resource_group_name
  location            = var.location
  use_existing        = var.use_existing_rg
  tags                = var.tags
}

# Création du storage account
resource "azurerm_storage_account" "this" {
  count = var.use_existing_storage ? 0 : 1

  name                            = var.storage_account_name
  resource_group_name             = module.resource_group.resource_group_name
  location                        = module.resource_group.location
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  account_kind                    = var.account_kind
  access_tier                     = var.access_tier
  https_traffic_only_enabled      = var.https_traffic_only_enabled
  min_tls_version                 = var.min_tls_version
  public_network_access_enabled   = var.public_network_access_enabled
  shared_access_key_enabled       = var.shared_access_key_enabled

  tags = var.tags
}

# Création des conteneurs blob
resource "azurerm_storage_container" "containers" {
  for_each = { for c in var.containers : c.name => c }

  name                 = each.value.name
  storage_account_id   = local.storage_account.id
  container_access_type = each.value.container_access_type
}

# Création des file shares
resource "azurerm_storage_share" "shares" {
  for_each = { for s in var.file_shares : s.name => s }

  name                 = each.value.name
  storage_account_id   = local.storage_account.id
  quota                = each.value.quota
}