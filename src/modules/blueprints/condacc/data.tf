# Ce "data" permet de retrouver le domaine onmicrosoft.com du tenant pour permettre dynamiquement d'exclure les breakglass
data "azuread_domains" "default" {
  only_initial = true
}

# Récupérer des informations sur le tenant Azure AD
data "azuread_client_config" "current" {}

# Récupérer les domaines du tenant Azure AD
data "azuread_domains" "current" {}

# Récupérer les objects id des breakglass pour les exclures des règles d'accès conditionnel
data "azuread_users" "breakglass" {
  user_principal_names = ["tenantadmin@${local.tenant_domain}"]
}

# Récupérer les objects id des utilisateurs exclus dans la règle d'accès conditionnel
data "azuread_user" "excluded_users" {
  for_each            = local.excluded_upn_map
  user_principal_name = each.key
}

# Récupérer les utilisateurs inclus (seulement si des utilisateurs spécifiques sont définis)
data "azuread_user" "included_users" {
  for_each            = local.included_upn_map
  user_principal_name = each.key
}

# =============================================================================
# DATA SOURCES POUR GROUPES - SUPPRIMÉS DEPUIS v2.3.0
# =============================================================================
# Les data sources pour les groupes ont été définitivement supprimés.
# Le module accepte UNIQUEMENT des object_id (UUID) pour les groupes.
# Tous les lookups doivent être faits dans le projet principal avant d'appeler le module.
# =============================================================================

# Récupérer les rôles Entra ID 
data "azuread_directory_roles" "roles" {}

# Récupérer les Service Principals à exclure (par nom uniquement)
data "azuread_service_principal" "excluded_applications" {
  for_each     = toset(local.excluded_app_names)
  display_name = each.value
}

# Récupérer les Service Principals à inclure (par nom uniquement)
data "azuread_service_principal" "included_applications" {
  for_each     = toset(local.included_app_names)
  display_name = each.value
}

# ===========================================
# DATA SOURCES - Service Principals pour Workload Identities
# ===========================================

# Récupérer les Service Principals à inclure pour workload identities (par nom uniquement)
data "azuread_service_principal" "included_workload_identities" {
  for_each     = toset(local.included_service_principal_names)
  display_name = each.value
}

# Récupérer les Service Principals à exclure pour workload identities (par nom uniquement)
data "azuread_service_principal" "excluded_workload_identities" {
  for_each     = toset(local.excluded_service_principal_names)
  display_name = each.value
}

# ===========================================
# DATA SOURCES - Détection automatique des named locations existantes
# ===========================================

# Data sources pour les named locations existantes détectées automatiquement
data "azuread_named_location" "included_existing" {
  for_each     = toset(local.included_existing_names)
  display_name = each.value
}

data "azuread_named_location" "excluded_existing" {
  for_each     = toset(local.excluded_existing_names)
  display_name = each.value
}
