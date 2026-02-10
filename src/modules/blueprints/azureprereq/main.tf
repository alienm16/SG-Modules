# ====================================
# Resource Group
# ====================================
module "resource_group" {
  count  = var.resource_group_name != null ? 1 : 0
  source = "../../resources/resource-group"

  subscription_id     = var.subscription_id
  subscription_name   = var.subscription_name
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

  subscription_id                                  = var.subscription_id
  subscription_name                                = var.subscription_name
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
  storage_network_rules_allowed_sites              = var.storage_network_rules_allowed_sites
  storage_network_rules_allow_custom_ip            = var.storage_network_rules_allow_custom_ip
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

  # Configuration des permissions Microsoft Graph (uniquement permissions d'application)
  dynamic "required_resource_access" {
    for_each = length(local.required_application_permissions) > 0 ? [1] : []

    content {
      resource_app_id = data.azuread_service_principal.microsoft_graph.client_id # Microsoft Graph

      dynamic "resource_access" {
        for_each = local.required_application_permissions

        content {
          id   = resource_access.value.id
          type = resource_access.value.type
        }
      }
    }
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

# Consentement automatique - Assignation des rôles d'application
resource "azuread_app_role_assignment" "grant_graph_permissions" {
  # Créer seulement si le consentement automatique est activé ET qu'il y a des permissions
  for_each = var.auto_grant_admin_consent && length(local.required_application_permissions) > 0 ? {
    for idx, permission in local.required_application_permissions :
    permission.id => permission
  } : {}

  app_role_id         = each.value.id
  principal_object_id = azuread_service_principal.ServicePrincipal.object_id
  resource_object_id  = data.azuread_service_principal.microsoft_graph.object_id

  depends_on = [
    azuread_application.AppRegistration,
    azuread_service_principal.ServicePrincipal
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

# ====================================
# RBAC Role Assignments
# ====================================

# Attribution du rôle "Reader" sur le Resource Group
resource "azurerm_role_assignment" "resource_group_reader" {
  count                = var.resource_group_name != null ? 1 : 0
  scope                = module.resource_group[0].resource_group_id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.ServicePrincipal.object_id

  depends_on = [
    azuread_service_principal.ServicePrincipal,
    module.resource_group
  ]
}

# Attribution du rôle "Storage Blob Data Contributor" sur le Storage Account
resource "azurerm_role_assignment" "terraform_state_contributor" {
  count                = var.storage_account_name != null ? 1 : 0
  scope                = module.storage_account[0].storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.ServicePrincipal.object_id

  depends_on = [
    azuread_service_principal.ServicePrincipal,
    module.storage_account
  ]
}

