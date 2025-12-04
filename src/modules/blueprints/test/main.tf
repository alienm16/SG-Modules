# ====================================
# Resource Group
# ====================================
module "resource_group" {
  count  = var.resource_group_name != null ? 1 : 0
  source = "../../resources/resource-group"

  resource_group_name = var.resource_group_name
  location            = var.location
  use_existing        = var.use_existing_rg
  tags                = var.tags
}

# ====================================
# Storage Account
# ====================================
module "storage_account" {
  count  = var.storage_account_name != null ? 1 : 0
  source = "../../resources/storage-account"

  storage_account_name                             = var.storage_account_name
  resource_group_name                              = var.resource_group_name != null ? module.resource_group[0].resource_group_name : var.resource_group_name
  location                                         = var.resource_group_name != null ? module.resource_group[0].location : var.location
  use_existing_rg                                  = var.resource_group_name != null ? true : var.use_existing_rg
  use_existing_storage                             = var.use_existing_storage
  storage_account_tier                             = var.storage_account_tier
  storage_account_replication_type                 = var.storage_account_replication_type
  storage_account_kind                             = var.storage_account_kind
  storage_access_tier                              = var.storage_access_tier
  storage_https_traffic_only_enabled               = var.storage_https_traffic_only_enabled
  storage_min_tls_version                          = var.storage_min_tls_version
  storage_public_network_access_enabled            = var.storage_public_network_access_enabled
  storage_shared_access_key_enabled                = var.storage_shared_access_key_enabled
  storage_network_rules_enabled                    = var.storage_network_rules_enabled
  storage_network_rules_default_action             = var.storage_network_rules_default_action
  storage_network_rules_ip_rules                   = var.storage_network_rules_ip_rules
  storage_network_rules_virtual_network_subnet_ids = var.storage_network_rules_virtual_network_subnet_ids
  storage_network_rules_bypass                     = var.storage_network_rules_bypass
  storage_containers                               = var.storage_containers
  storage_file_shares                              = var.storage_file_shares
  tags                                             = var.tags

  depends_on = [module.resource_group]
}

# ====================================
# Azure AD Application Registration
# ====================================
# Création de l'application registration AVEC les permissions (méthode qui fonctionne)
resource "azuread_application" "AppRegistration" {
  display_name            = var.app_name
  description             = var.app_description
  prevent_duplicate_names = true
  owners                  = [data.azuread_client_config.current.object_id]
  sign_in_audience        = "AzureADMyOrg"

  # Configuration API
  api {
    mapped_claims_enabled          = false
    requested_access_token_version = 2
  }

}

# Création du service principal
resource "azuread_service_principal" "ServicePrincipal" {
  client_id                    = azuread_application.AppRegistration.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]

  depends_on = [
    azuread_application.AppRegistration
  ]

}

# Configuration des Federated Credentials pour les branches
resource "azuread_application_federated_identity_credential" "github_branches" {
  application_id = azuread_application.AppRegistration.id
  display_name   = "github-${var.github_repository}-${var.github_branch}-${var.tenant}"
  description    = "GitHub Actions credential for ${var.github_organization}/${var.github_repository} on branch ${var.github_branch} - ENV: ${upper(var.tenant)}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_organization}/${var.github_repository}:ref:refs/heads/${var.github_branch}"
}

# Configuration des Federated Credentials pour les Pull Requests
resource "azuread_application_federated_identity_credential" "github_pull_requests" {
  application_id = azuread_application.AppRegistration.id
  display_name   = "github-${var.github_repository}-pull-request-${var.tenant}"
  description    = "GitHub Actions credential for ${var.github_organization}/${var.github_repository} pull requests - ENV: ${upper(var.tenant)}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_organization}/${var.github_repository}:pull_request"
}

