# =============================================================================
# LOGIQUE D'ENVIRONNEMENT ET D'ÉTAT - UTILISE var.tenant DU CI/CD
# =============================================================================

locals {
  # Déterminer l'état final basé sur var.tenant (vient du CI/CD) et les overrides spécifiques
  final_state = (
    # Priorité aux variables spécifiques par environnement si définies
    var.tenant == "lab" && var.state_in_lab != null ? var.state_in_lab :
    var.tenant == "dev" && var.state_in_dev != null ? var.state_in_dev :
    var.tenant == "prod" && var.state_in_prod != null ? var.state_in_prod :
    # Sinon utiliser la variable state générale
    var.state
  )

  # Validation pour s'assurer qu'un état est toujours défini
  state_validation = var.enable_state_validation ? (
    local.final_state != null && local.final_state != "" ? true :
    tobool("Erreur: Aucun état valide défini pour l'environnement ${var.tenant}")
  ) : true
}

# =============================================================================
# GESTION DES DOMAINES ET ENVIRONNEMENTS
# =============================================================================

locals {
  # Récupérer tous les domaines du tenant Azure AD
  all_domains = data.azuread_domains.current.domains

  # Filtrer les domaines pour déterminer l'environnement actuel
  filtered_lab_domains = [
    for domain in local.all_domains : domain.domain_name
    if domain.domain_name == "lab.ca"
  ]

  filtered_dev_domains = [
    for domain in local.all_domains : domain.domain_name
    if domain.domain_name == "dev.ca"
  ]

  # Déterminer l'environnement actuel (lab, dev, prod) en fonction du domaine présent
  current_env = length(local.filtered_lab_domains) > 0 ? "lab" : (
    length(local.filtered_dev_domains) > 0 ? "dev" : "prod"
  )

  # Correspondance entre environnements et domaines
  domain_mapping = {
    "lab" = {
      main  = "lab.ca"
      admin = "admin.lab.ca"
    }
    "dev" = {
      main  = "dev.ca"
      admin = "admin.dev.ca"
    }
    "prod" = {
      main  = "SG.ca"
      admin = "admin.SG.ca"
    }
  }

  # Domaine principal et admin pour l'environnement actuel
  default_domain       = lookup(local.domain_mapping[local.current_env], "main", null)
  default_admin_domain = lookup(local.domain_mapping[local.current_env], "admin", null)
}

# =============================================================================
# GESTION DES COMPTES BREAKGLASS
# =============================================================================

locals {
  tenant_domain  = data.azuread_domains.default.domains.0.domain_name
  breakglass_upn = data.azuread_users.breakglass.user_principal_names
  breakglass_id  = [data.azuread_users.breakglass.object_ids]
}
