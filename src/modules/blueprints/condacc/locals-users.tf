# =============================================================================
# GESTION DES UTILISATEURS - INCLUSIONS ET EXCLUSIONS
# =============================================================================

locals {
  # Valeurs spéciales pour les inclusions/exclusions
  special_values = ["GuestsOrExternalUsers", "All"]
}

# =============================================================================
# TRAITEMENT DES UTILISATEURS EXCLUS
# =============================================================================

locals {
  # Séparer les utilisateurs normaux des valeurs spéciales pour excluded_users
  excluded_user_list = [
    for user in var.excluded_users : user
    if !contains(local.special_values, user)
  ]

  # Traitement des utilisateurs exclus normaux (avec support pour le préfixe admin:)
  excluded_normal_upns = [
    for user in local.excluded_user_list :
    {
      original = user,
      is_admin = startswith(user, "admin:"),
      username = startswith(user, "admin:") ? replace(user, "admin:", "") : user,
      domain   = startswith(user, "admin:") ? local.default_admin_domain : local.default_domain
    }
  ]

  # Générer la liste finale des UPNs pour les exclusions
  excluded_final_upns = [
    for user in local.excluded_normal_upns : "${user.username}@${user.domain}"
  ]

  # Créer un objet pour faciliter les lookups des utilisateurs exclus
  excluded_upn_map = {
    for upn in local.excluded_final_upns : upn => upn
  }

  # Récupérer les valeurs spéciales pour les exclusions
  excluded_special_users = [
    for user in var.excluded_users : user
    if contains(["GuestsOrExternalUsers", "All"], user)
  ]
}

# =============================================================================
# TRAITEMENT DES UTILISATEURS INCLUS
# =============================================================================

locals {
  # Vérifier si "All" est présent dans included_users
  has_all_included = contains(var.included_users, "All")

  # Vérifier si "GuestsOrExternalUsers" est présent
  has_guests_included = contains(var.included_users, "GuestsOrExternalUsers")

  # Créer une liste d'utilisateurs non-spéciaux
  regular_included_users = [
    for user in var.included_users : user
    if !contains(local.special_values, user)
  ]

  # Validation de configuration
  configuration_error = local.has_all_included && (local.has_guests_included || length(local.regular_included_users) > 0) ? "Erreur: 'All' doit être utilisé seul, sans 'GuestsOrExternalUsers' ni autres utilisateurs spécifiques" : ""

  # Lever une erreur si la configuration n'est pas valide
  check_configuration = local.configuration_error != "" ? tobool(local.configuration_error) : true

  # Liste finale des utilisateurs à traiter (vide si All est présent)
  included_user_list = local.has_all_included ? [] : local.regular_included_users

  # Traitement des valeurs spéciales pour inclusion
  included_special_users = local.has_all_included ? ["All"] : (local.has_guests_included ? ["GuestsOrExternalUsers"] : [])

  # Traitement des utilisateurs inclus normaux (avec support pour le préfixe admin:)
  included_normal_upns = [
    for user in local.included_user_list :
    {
      original = user,
      is_admin = startswith(user, "admin:"),
      username = startswith(user, "admin:") ? replace(user, "admin:", "") : user,
      domain   = startswith(user, "admin:") ? local.default_admin_domain : local.default_domain
    }
  ]

  # Générer la liste finale des UPNs pour les inclusions
  included_final_upns = [
    for user in local.included_normal_upns : "${user.username}@${user.domain}"
  ]

  # Créer un objet pour faciliter les lookups des utilisateurs inclus
  included_upn_map = {
    for upn in local.included_final_upns : upn => upn
  }
}
