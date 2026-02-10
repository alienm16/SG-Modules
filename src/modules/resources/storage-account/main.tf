# Gestion du resource group
module "resource_group" {
  source = "../resource-group"

  subscription_id     = var.subscription_id
  subscription_name   = var.subscription_name
  resource_group_name = var.resource_group_name
  location            = var.location
  use_existing        = var.use_existing_rg
  tags                = var.tags
}

# Création du storage account
resource "azurerm_storage_account" "this" {
  count = var.use_existing_storage ? 0 : 1

  name                          = var.storage_account_name
  resource_group_name           = module.resource_group.resource_group_name
  location                      = module.resource_group.location
  account_tier                  = var.storage_account_tier
  account_replication_type      = var.storage_account_replication_type
  account_kind                  = var.storage_account_kind
  access_tier                   = var.storage_access_tier
  https_traffic_only_enabled    = var.storage_https_traffic_only_enabled
  min_tls_version               = var.storage_min_tls_version
  public_network_access_enabled = var.storage_public_network_access_enabled
  shared_access_key_enabled     = var.storage_shared_access_key_enabled

  dynamic "network_rules" {
    for_each = var.storage_network_rules_enabled ? [1] : []
    content {
      default_action             = var.storage_network_rules_default_action
      ip_rules                   = local.resolved_ip_rules
      virtual_network_subnet_ids = var.storage_network_rules_virtual_network_subnet_ids
      bypass                     = var.storage_network_rules_bypass
    }
  }

  tags = var.tags
}

# Création des conteneurs blob
resource "azurerm_storage_container" "containers" {
  for_each = { for c in var.storage_containers : c.name => c }

  name                  = each.value.name
  storage_account_id    = local.storage_account.id
  container_access_type = each.value.container_access_type
}

# Création des file shares
resource "azurerm_storage_share" "shares" {
  for_each = { for s in var.storage_file_shares : s.name => s }

  name               = each.value.name
  storage_account_id = local.storage_account.id
  quota              = each.value.quota
}
