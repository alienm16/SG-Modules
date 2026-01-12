# =============================================================================
# VALIDATIONS CENTRALISÉES POUR DÉTECTER LES CONFIGURATIONS CONFLICTUELLES
# =============================================================================

locals {
  # =============================================================================
  # VALIDATIONS POUR LES UTILISATEURS
  # =============================================================================

  # Validation 1: "All" ne peut pas être combiné avec d'autres utilisateurs spécifiques
  user_all_conflict = contains(var.included_users, "All") && (
    contains(var.included_users, "GuestsOrExternalUsers") ||
    length([for user in var.included_users : user if !contains(["All", "GuestsOrExternalUsers"], user)]) > 0
  )

  # Validation 2: Si des utilisateurs spécifiques sont définis, on ne peut pas avoir "All"
  user_specific_with_all = length(var.included_users) > 1 && contains(var.included_users, "All")

  # =============================================================================
  # VALIDATIONS POUR LES APPLICATIONS
  # =============================================================================

  # Validation 3: "All" ne peut pas être combiné avec des applications spécifiques
  app_all_conflict = contains(var.applications_included_applications, "All") && (
    length([for app in var.applications_included_applications : app if app != "All"]) > 0
  )

  # Validation 4: "None" ne peut pas être combiné avec d'autres applications
  app_none_conflict = contains(var.applications_included_applications, "None") && (
    length([for app in var.applications_included_applications : app if app != "None"]) > 0
  )

  # Validation 5: "All" et "None" ne peuvent pas être ensemble
  app_all_none_conflict = contains(var.applications_included_applications, "All") && contains(var.applications_included_applications, "None")

  # =============================================================================
  # VALIDATIONS POUR LES RÔLES
  # =============================================================================

  # Validation 6: "All" ne peut pas être combiné avec des rôles spécifiques
  role_all_conflict = contains(var.included_roles, "All") && (
    length([for role in var.included_roles : role if role != "All"]) > 0
  )

  # =============================================================================
  # VALIDATIONS POUR LES LOCATIONS
  # =============================================================================

  # Validation 7: "All" ne peut pas être combiné avec d'autres locations
  location_all_conflict = contains(var.condition_included_locations, "All") && (
    length([for loc in var.condition_included_locations : loc if loc != "All"]) > 0
  )

  # Validation 8: "AllTrusted" ne peut pas être combiné avec d'autres locations
  location_all_trusted_conflict = contains(var.condition_included_locations, "AllTrusted") && (
    length([for loc in var.condition_included_locations : loc if loc != "AllTrusted"]) > 0
  )

  # Validation 9: Même validation pour les exclusions
  location_excluded_all_trusted_conflict = contains(var.condition_excluded_locations, "AllTrusted") && (
    length([for loc in var.condition_excluded_locations : loc if loc != "AllTrusted"]) > 0
  )

  # =============================================================================
  # VALIDATIONS POUR LES PLATEFORMES
  # =============================================================================

  # Validation 10: "all" ne peut pas être combiné avec des plateformes spécifiques
  platform_all_conflict = var.condition_included_platforms != null && (
    contains(var.condition_included_platforms, "all") && (
      length([for platform in var.condition_included_platforms : platform if platform != "all"]) > 0
    )
  )

  # =============================================================================
  # VALIDATIONS POUR LES GRANT CONTROLS
  # =============================================================================

  # Validation 11: "block" ne peut pas être combiné avec d'autres contrôles
  grant_block_conflict = contains(var.grant_built_in_controls, "block") && (
    length([for control in var.grant_built_in_controls : control if control != "block"]) > 0
  )

  # Validation 12: approvedApplication et compliantApplication nécessitent des plateformes mobiles
  grant_app_platform_conflict = (
    contains(var.grant_built_in_controls, "approvedApplication") ||
    contains(var.grant_built_in_controls, "compliantApplication")
    ) && var.condition_included_platforms != null && (
    !anytrue([for platform in var.condition_included_platforms : contains(["iOS", "android", "windows"], platform)]) ||
    anytrue([for platform in var.condition_included_platforms : contains(["linux", "macOS", "windowsPhone"], platform)])
  )

  # =============================================================================
  # VALIDATIONS POUR LES WORKLOAD IDENTITIES
  # =============================================================================

  # Validation 13: "All" et "ServicePrincipalsInMyTenant" ne peuvent pas être avec des SPs spécifiques
  workload_all_conflict = (
    contains(var.workload_identities_included_service_principals, "All") ||
    contains(var.workload_identities_included_service_principals, "ServicePrincipalsInMyTenant")
    ) && (
    length([for sp in var.workload_identities_included_service_principals : sp
    if !contains(["All", "ServicePrincipalsInMyTenant"], sp)]) > 0
  )

  # =============================================================================
  # COMPILATION DE TOUTES LES ERREURS
  # =============================================================================

  validation_errors = compact([
    local.user_all_conflict ? "ERREUR: 'All' dans included_users ne peut pas être combiné avec d'autres utilisateurs ou 'GuestsOrExternalUsers'" : "",
    local.app_all_conflict ? "ERREUR: 'All' dans applications_included_applications ne peut pas être combiné avec d'autres applications" : "",
    local.app_none_conflict ? "ERREUR: 'None' dans applications_included_applications ne peut pas être combiné avec d'autres applications" : "",
    local.app_all_none_conflict ? "ERREUR: 'All' et 'None' ne peuvent pas être utilisés ensemble dans applications_included_applications" : "",
    local.role_all_conflict ? "ERREUR: 'All' dans included_roles ne peut pas être combiné avec des rôles spécifiques" : "",
    local.location_all_conflict ? "ERREUR: 'All' dans condition_included_locations ne peut pas être combiné avec d'autres locations" : "",
    local.location_all_trusted_conflict ? "ERREUR: 'AllTrusted' dans condition_included_locations ne peut pas être combiné avec d'autres locations" : "",
    local.location_excluded_all_trusted_conflict ? "ERREUR: 'AllTrusted' dans condition_excluded_locations ne peut pas être combiné avec d'autres locations" : "",
    local.platform_all_conflict ? "ERREUR: 'all' dans condition_included_platforms ne peut pas être combiné avec des plateformes spécifiques" : "",
    local.grant_block_conflict ? "ERREUR: 'block' dans grant_built_in_controls ne peut pas être combiné avec d'autres contrôles" : "",
    local.grant_app_platform_conflict ? "ERREUR: 'approvedApplication' ou 'compliantApplication' nécessitent des plateformes iOS, android ou windows uniquement" : "",
    local.workload_all_conflict ? "ERREUR: 'All' ou 'ServicePrincipalsInMyTenant' ne peuvent pas être combinés avec des service principals spécifiques" : ""
  ])

  # Vérification finale : si des erreurs existent, lever une exception
  validation_check = length(local.validation_errors) > 0 ? (
    tobool("Configuration invalide détectée:\n${join("\n", local.validation_errors)}")
  ) : true
}
