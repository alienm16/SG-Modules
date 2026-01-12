# ===============================================
# LOCALS - Détection automatique dans la variable principale
# ===============================================

locals {
  # Conversion des null en listes vides AVANT toute utilisation
  safe_included_locations = var.condition_included_locations != null ? var.condition_included_locations : []
  safe_excluded_locations = var.condition_excluded_locations != null ? var.condition_excluded_locations : []
  safe_included_resources = var.condition_included_location_resources != null ? var.condition_included_location_resources : []
  safe_excluded_resources = var.condition_excluded_location_resources != null ? var.condition_excluded_location_resources : []

  # Conditions d'utilisation
  has_included_locations = length(local.safe_included_locations) > 0 || length(local.safe_included_resources) > 0
  has_excluded_locations = length(local.safe_excluded_locations) > 0 || length(local.safe_excluded_resources) > 0
  use_locations_block    = local.has_included_locations || local.has_excluded_locations

  # Mapping des valeurs spéciales
  special_values_loc = {
    "All"                                    = "All"
    "AllTrusted"                             = "AllTrusted"
    "Multifactor authentication trusted IPs" = "00000000-0000-0000-0000-000000000000"
  }

  # DÉTECTION AUTOMATIQUE dans condition_included_locations
  included_special_values = [
    for location in local.safe_included_locations : location
    if contains(["All", "AllTrusted", "Multifactor authentication trusted IPs"], location)
  ]

  included_direct_ids = [
    for location in local.safe_included_locations : location
    if can(regex("^/identity/conditionalAccess/namedLocations/", location))
  ]

  # Les named locations existantes = tout ce qui n'est ni spécial ni ID direct
  included_existing_names = [
    for location in local.safe_included_locations : location
    if !contains(["All", "AllTrusted", "Multifactor authentication trusted IPs"], location) &&
    !can(regex("^/identity/conditionalAccess/namedLocations/", location))
  ]

  # DÉTECTION AUTOMATIQUE dans condition_excluded_locations
  excluded_special_values = [
    for location in local.safe_excluded_locations : location
    if contains(["All", "AllTrusted", "Multifactor authentication trusted IPs"], location)
  ]

  excluded_direct_ids = [
    for location in local.safe_excluded_locations : location
    if can(regex("^/identity/conditionalAccess/namedLocations/", location))
  ]

  excluded_existing_names = [
    for location in local.safe_excluded_locations : location
    if !contains(["All", "AllTrusted", "Multifactor authentication trusted IPs"], location) &&
    !can(regex("^/identity/conditionalAccess/namedLocations/", location))
  ]

  # Solution robuste pour extraire l'ID pur - regex pour capturer seulement l'UUID
  clean_included_resources = [
    for resource_id in local.safe_included_resources :
    # Utiliser regex pour extraire seulement l'UUID, peu importe le format d'entrée
    can(regex("[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}", resource_id)) ?
    regex("[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}", resource_id) :
    resource_id
  ]

  clean_excluded_resources = [
    for resource_id in local.safe_excluded_resources :
    # Utiliser regex pour extraire seulement l'UUID, peu importe le format d'entrée
    can(regex("[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}", resource_id)) ?
    regex("[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}", resource_id) :
    resource_id
  ]
  # Extraire les IDs des paths complets
  included_path_ids = [
    for location in local.included_direct_ids :
    substr(location, length("/identity/conditionalAccess/namedLocations/"), -1)
  ]

  excluded_path_ids = [
    for location in local.excluded_direct_ids :
    substr(location, length("/identity/conditionalAccess/namedLocations/"), -1)
  ]



  # Debug final - ajouter une validation pour voir exactement ce qui est passé
  validated_final_included_locations = [
    for location in local.final_included_locations :
    # Appliquer le nettoyage UUID à TOUT ce qui passe ici
    can(regex("[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}", location)) ?
    regex("[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}", location) :
    location
  ]

  validated_final_excluded_locations = [
    for location in local.final_excluded_locations :
    # Appliquer le nettoyage UUID à TOUT ce qui passe ici
    can(regex("[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}", location)) ?
    regex("[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}", location) :
    location
  ]
  # Construction des listes finales - avec nettoyage UUID forcé sur TOUT
  final_included_locations = local.has_included_locations ? [
    for location in compact(flatten([
      # Si "All" est présent, priorité absolue
      contains(local.included_special_values, "All") ? ["All"] : flatten([
        # Valeurs spéciales (sauf All)
        [for loc in local.included_special_values : local.special_values_loc[loc] if loc != "All"],

        # IDs extraits des paths complets
        local.included_path_ids,

        # Named locations existantes résolues via data source
        [for name, location in data.azuread_named_location.included_existing : location.id],

        # Ressources créées localement - déjà nettoyées par regex
        local.clean_included_resources
      ])
    ])) :
    # NETTOYAGE UUID FINAL sur TOUT
    can(regex("[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}", location)) ?
    regex("[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}", location) :
    location
  ] : []

  final_excluded_locations = local.has_excluded_locations ? [
    for location in compact(flatten([
      # Valeurs spéciales
      [for loc in local.excluded_special_values : local.special_values_loc[loc]],

      # IDs extraits des paths complets
      local.excluded_path_ids,

      # Named locations existantes résolues via data source
      [for name, location in data.azuread_named_location.excluded_existing : location.id],

      # Ressources créées localement - déjà nettoyées par regex
      local.clean_excluded_resources
    ])) :
    # NETTOYAGE UUID FINAL sur TOUT
    can(regex("[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}", location)) ?
    regex("[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}", location) :
    location
  ] : []
}
