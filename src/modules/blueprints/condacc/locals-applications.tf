# =============================================================================
# GESTION DES APPLICATIONS ET DÉTECTION AUTOMATIQUE
# =============================================================================

locals {
  # Regex pour détecter un client_id (format UUID)
  client_id_regex = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
}

# =============================================================================
# APPLICATIONS EXCLUES
# =============================================================================

locals {
  # Apps exclues : séparer les noms des client_ids
  excluded_app_names = var.applications_excluded_applications == null ? [] : [
    for name in var.applications_excluded_applications :
    name if !can(regex(local.client_id_regex, name)) &&
    lower(name) != "microsoftadminportals" &&
    lower(name) != "office365"
  ]

  excluded_client_ids = var.applications_excluded_applications == null ? [] : [
    for id in var.applications_excluded_applications :
    id if can(regex(local.client_id_regex, id))
  ]

  excluded_special_apps = var.applications_excluded_applications == null ? [] : [
    for name in var.applications_excluded_applications :
    name if lower(name) == "microsoftadminportals" ||
    lower(name) == "office365"
  ]
}

# =============================================================================
# APPLICATIONS INCLUSES
# =============================================================================

locals {
  # Apps incluses : séparer les noms des client_ids
  included_app_names = [
    for name in var.applications_included_applications :
    name if !can(regex(local.client_id_regex, name)) &&
    lower(name) != "microsoftadminportals" &&
    lower(name) != "office365" &&
    name != "All" &&
    name != "None"
  ]

  included_client_ids = [
    for id in var.applications_included_applications :
    id if can(regex(local.client_id_regex, id))
  ]

  included_special_apps = [
    for name in var.applications_included_applications :
    name if lower(name) == "microsoftadminportals" ||
    lower(name) == "office365"
  ]

  # Vérifier si on utilise "All" ou "None"
  use_all_apps  = length([for name in var.applications_included_applications : name if name == "All"]) > 0
  use_none_apps = length([for name in var.applications_included_applications : name if name == "None"]) > 0
}
