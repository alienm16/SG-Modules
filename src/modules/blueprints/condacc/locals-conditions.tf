# =============================================================================
# GESTION DES CONDITIONS ET BLOCS CONDITIONNELS
# =============================================================================

# Gestion des User Actions
locals {
  use_included_user_actions = length(var.included_user_actions) > 0
}

# Gestion des Plateformes
locals {
  use_included_platforms = var.condition_included_platforms != null && length(var.condition_included_platforms) > 0
  use_excluded_platforms = var.condition_excluded_platforms != null && length(var.condition_excluded_platforms) > 0
  # Détermine si on a besoin du bloc platforms du tout
  use_platforms_block = local.use_included_platforms || local.use_excluded_platforms
}

# Gestion des Devices
locals {
  use_device_filter = var.condition_device_filter_mode != null && var.condition_device_filter_rule != null
  use_devices_block = local.use_device_filter
}

# Gestion des Rôles
locals {
  # Vérifier si "All" est présent dans included_roles
  has_all_included_roles = contains(var.included_roles, "All")

  # Si "All" est présent, utiliser tous les rôles disponibles, sinon utiliser la liste fournie
  final_included_roles = local.has_all_included_roles ? [
    for role in data.azuread_directory_roles.roles.roles : role.display_name
  ] : var.included_roles
}

# =============================================================================
# GESTION DES WORKLOAD IDENTITIES
# =============================================================================

locals {
  # Vérifier si on utilise "All" pour les service principals inclus
  use_all_service_principals = contains(var.workload_identities_included_service_principals, "All") || contains(var.workload_identities_included_service_principals, "ServicePrincipalsInMyTenant")

  # Liste des service principals inclus (excluant "All" et "ServicePrincipalsInMyTenant")
  included_service_principal_names = [
    for name in var.workload_identities_included_service_principals : name
    if name != "All" && name != "ServicePrincipalsInMyTenant"
  ]

  # Liste des service principals exclus
  excluded_service_principal_names = var.workload_identities_excluded_service_principals

  # Vérifier si on utilise un filtre pour les workload identities
  use_workload_filter = var.workload_identities_filter_mode != null && var.workload_identities_filter_rule != null && var.workload_identities_filter_mode != "" && var.workload_identities_filter_rule != ""

  # Vérifier si on a besoin du bloc client_applications (workload identities)
  use_workload_identities_block = (
    length(var.workload_identities_included_service_principals) > 0 ||
    length(var.workload_identities_excluded_service_principals) > 0 ||
    local.use_workload_filter
  )
}
