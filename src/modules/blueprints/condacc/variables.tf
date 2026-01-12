variable "tenant" {
  description = "Environnement du tenant (lab, dev, prod) - automatiquement fourni par le CI/CD. Cette variable est utilisée pour déterminer les domaines et états spécifiques à l'environnement."
  type        = string
  default     = null

  validation {
    condition     = var.tenant == null || contains(["lab", "dev", "prod"], var.tenant)
    error_message = "La valeur doit être 'lab', 'dev', 'prod' ou null."
  }
}

variable "display_name" {
  type        = string
  description = "Le nom de la règle d'accès conditionnel"
}
variable "state" {
  description = "L'état de la règle d'accès conditionnel"
  type        = string
  default     = "enabledForReportingButNotEnforced"

  validation {
    condition     = contains(["enabled", "disabled", "enabledForReportingButNotEnforced"], var.state)
    error_message = "L'état doit être l'une des valeurs suivantes: 'enabled', 'disabled', or 'enabledForReportingButNotEnforced'."
  }
}

# Variables optionnelles pour override l'état par environnement
variable "state_in_lab" {
  description = "État spécifique pour l'environnement lab (optionnel)"
  type        = string
  default     = null

  validation {
    condition     = var.state_in_lab == null || contains(["enabled", "disabled", "enabledForReportingButNotEnforced"], var.state_in_lab)
    error_message = "L'état doit être l'une des valeurs suivantes: 'enabled', 'disabled', 'enabledForReportingButNotEnforced', ou null."
  }
}

# Validation globale pour s'assurer qu'au moins un état est défini
variable "enable_state_validation" {
  description = "Active la validation des états (interne)"
  type        = bool
  default     = true
}

variable "state_in_dev" {
  description = "État spécifique pour l'environnement dev (optionnel)"
  type        = string
  default     = null

  validation {
    condition     = var.state_in_dev == null || contains(["enabled", "disabled", "enabledForReportingButNotEnforced"], var.state_in_dev)
    error_message = "L'état doit être l'une des valeurs suivantes: 'enabled', 'disabled', 'enabledForReportingButNotEnforced', ou null."
  }
}

variable "state_in_prod" {
  description = "État spécifique pour l'environnement prod (optionnel)"
  type        = string
  default     = null

  validation {
    condition     = var.state_in_prod == null || contains(["enabled", "disabled", "enabledForReportingButNotEnforced"], var.state_in_prod)
    error_message = "L'état doit être l'une des valeurs suivantes: 'enabled', 'disabled', 'enabledForReportingButNotEnforced', ou null."
  }
}

##############################################
##### Variables pour le block CONDITIONS #####
############################################## 

variable "condition_client_app_types" {
  description = "La liste des type d'application inclus dans la règle d'accès conditionnel."
  type        = list(string)
  default     = ["all"]

  validation {
    condition     = length(var.condition_client_app_types) == 1 && var.condition_client_app_types[0] == "all" || !contains(var.condition_client_app_types, "all")
    error_message = "Le type de 'Client app' peut être 'all' uniquement ou une combinaison de: 'browser', 'mobileAppsAndDesktopClients', 'exchangeActiveSync', 'easSupported', 'other'."
  }
}

variable "condition_insider_risk_levels" {
  description = "Variable pour le niveau de risque pour 'insider risk'."
  type        = string
  default     = null

  validation {
    condition     = var.condition_insider_risk_levels == null ? true : contains(["minor", "moderate", "elevated"], var.condition_insider_risk_levels)
    error_message = "La valeur doit être 'minor', 'moderate', 'elevate' ou vide en mettant des double quote."
  }
}

variable "condition_service_principal_risk_levels" {
  description = "Variable pour le niveau de risque pour 'service principal risk'."
  type        = list(string)
  default     = null

  validation {
    #condition     = var.condition_service_principal_risk_levels == null ? true : contains(["high", "medium", "low", "none"], var.condition_service_principal_risk_levels)
    condition = var.condition_service_principal_risk_levels == null ? true : alltrue([for risk in var.condition_service_principal_risk_levels : contains(["high", "medium", "low", "none"], risk)])
    #condition     = var.condition_service_principal_risk_levels == null || alltrue([for risk in var.condition_service_principal_risk_levels : contains(["high", "medium", "low", "none"], risk)])
    error_message = "La valeur doit être 'high', 'medium', 'low', 'none' ou null."
  }
}

variable "condition_sign_in_risk_levels" {
  description = "Variable pour le niveau de risque pour 'sign in risk'."
  type        = list(string)
  default     = null

  validation {
    condition     = var.condition_sign_in_risk_levels == null ? true : alltrue([for risk in var.condition_sign_in_risk_levels : contains(["high", "medium", "low", "none"], risk)])
    error_message = "La valeur doit être 'high', 'medium', 'low', 'none' ou null."
  }
}

variable "condition_user_risk_levels" {
  description = "Variable pour le niveau de risque pour 'user risk'."
  type        = list(string)
  default     = null

  validation {
    condition     = var.condition_user_risk_levels == null ? true : alltrue([for risk in var.condition_user_risk_levels : contains(["high", "medium", "low", "none"], risk)])
    error_message = "La valeur doit être 'high', 'medium', 'low', 'none' ou null."
  }
}

variable "condition_included_platforms" {
  description = "La liste des type de platforms à inclure pour la règle d'accès conditionnel."
  type        = list(string)
  default     = null # Changement: default à null

  validation {
    condition = var.condition_included_platforms == null ? true : alltrue([
      for platform in var.condition_included_platforms :
      contains(["android", "iOS", "windows", "linux", "macOS", "windowsPhone", "all"], platform)
    ])
    error_message = "La valeur doit être 'all', 'android', 'iOS', 'windows', 'linux', 'macOS', 'windowsPhone' ou null."
  }

  validation {
    condition     = var.condition_included_platforms == null ? true : !(contains(var.condition_included_platforms, "all") && length(var.condition_included_platforms) > 1)
    error_message = "Si 'all' est utilisé, il doit être la seule valeur dans la liste."
  }
}

variable "condition_excluded_platforms" {
  description = "La liste des type de platforms à exclure pour la règle d'accès conditionnel."
  type        = list(string)
  default     = null

  validation {
    condition = var.condition_excluded_platforms == null ? true : alltrue([
      for platform in var.condition_excluded_platforms :
      contains(["android", "iOS", "windows", "linux", "macOS", "windowsPhone"], platform)
    ])
    error_message = "La valeur doit être 'android', 'iOS', 'windows', 'macOS', 'windowsPhone' ou null."
  }
}

# ===============================================
# VARIABLES D'ENTRÉE - Ajout de depends_on pour gérer les dépendances
# ===============================================

variable "condition_included_locations" {
  description = "Liste des locations incluses (IDs directs, valeurs spéciales, noms de named locations existantes)"
  type        = list(string)
  default     = []

  validation {
    condition = length(var.condition_included_locations) == 0 || (
      # Si "All" est présent, doit être seul
      contains(var.condition_included_locations, "All") ? length(var.condition_included_locations) == 1 :
      # Si "AllTrusted" est présent, doit être seul
      contains(var.condition_included_locations, "AllTrusted") ? length(var.condition_included_locations) == 1 :
      # Sinon, toute combinaison est permise (y compris avec "Multifactor authentication trusted IPs")
      true
    )
    error_message = "Si 'All' ou 'AllTrusted' est utilisé, il doit être la seule valeur dans la liste."
  }
}

variable "condition_excluded_locations" {
  description = "Liste des locations exclues (IDs directs, valeurs spéciales, noms de named locations existantes)"
  type        = list(string)
  default     = []

  validation {
    condition = length(var.condition_excluded_locations) == 0 || (
      # "All" n'est pas autorisé dans les exclusions
      !contains(var.condition_excluded_locations, "All") &&
      # Si "AllTrusted" est présent, doit être seul
      (contains(var.condition_excluded_locations, "AllTrusted") ? length(var.condition_excluded_locations) == 1 : true)
    )
    error_message = "'All' ne peut pas être utilisé dans les exclusions. Si 'AllTrusted' est utilisé, il doit être la seule valeur dans la liste."
  }
}

variable "condition_included_location_resources" {
  description = "Liste des IDs de ressources azuread_named_location créées localement (format: azuread_named_location.name.id)"
  type        = list(string)
  default     = []
}

variable "condition_excluded_location_resources" {
  description = "Liste des IDs de ressources azuread_named_location créées localement (format: azuread_named_location.name.id)"
  type        = list(string)
  default     = []
}

variable "propagation_delay" {
  description = "Délai en secondes pour attendre la propagation des named locations dans Azure AD"
  type        = string
  default     = "15s"
}

################################################
##### Variables pour le block APPLICATIONS #####
################################################

variable "applications_excluded_applications" {
  description = "La liste des applications à exclure de la règle d'accès conditionnel. Peut contenir des noms (display_name) ou des client_id (format UUID)."
  type        = list(string)
  default     = null
}

variable "applications_included_applications" {
  description = "La liste des applications à inclure de la règle d'accès conditionnel. Peut contenir des noms (display_name) ou des client_id (format UUID)."
  type        = list(string)
  default     = ["All"]

  validation {
    condition     = !contains(var.applications_included_applications, "all")
    error_message = "Utilisez 'All' avec un A majuscule, pas 'all' en minuscules."
  }

  validation {
    condition     = !(contains(var.applications_included_applications, "All") && length(var.applications_included_applications) > 1)
    error_message = "Si 'All' est utilisé, il doit être la seule valeur dans la liste."
  }

  validation {
    condition     = !(contains(var.applications_included_applications, "None") && length(var.applications_included_applications) > 1)
    error_message = "Si 'None' est utilisé, il doit être la seule valeur dans la liste."
  }
}


variable "included_user_actions" {
  description = "La liste des 'user actions' à inclure dans la règle d'accès conditionnel."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.included_user_actions) == 0 || alltrue([for action in var.included_user_actions : action == "urn:user:registerdevice" || action == "urn:user:registersecurityinfo"])
    error_message = "Les valeurs permise sont: 'urn:user:registerdevice' et 'urn:user:registersecurityinfo'."
  }
}

variable "authentication_context" {
  description = "La liste des 'authentication context' à inclure dans la règle d'accès conditonnel."
  type        = list(string)
  default     = []
}

#########################################
##### Variables pour le block USERS #####
#########################################

variable "excluded_users" {
  description = "La liste des noms à exclure de la règle d'accès conditionnel. Utiliser le prenom.nom pour les domaines par défaut, admin:prenom.nom pour les domaines admin par défaut, 'GuestsOrExternalUsers' pour les invités, ou 'All' pour tous les utilisateurs."
  type        = list(string)
  default     = []
}

variable "excluded_groups" {
  description = "La liste des groupes à exclure de la règle d'accès conditionnel. Peut contenir des noms (display_name) ou des object_id (format UUID). Le module détecte automatiquement le format."
  type        = list(string)
  default     = []
}
variable "excluded_roles" {
  description = "La liste des rôles Entra ID à exclure de la règle d'accès conditionnel."
  type        = list(string)
  default     = []
}
variable "included_groups" {
  description = "La liste des groupes à inclure dans la règle d'accès conditionnel. Peut contenir des noms (display_name) ou des object_id (format UUID). Le module détecte automatiquement le format."
  type        = list(string)
  default     = []
}
variable "included_roles" {
  description = "La liste des rôles Entra ID à inclure dans la règle d'accès conditionnel. Utilisez 'All' pour inclure tous les rôles automatiquement (plus de 70 rôles), ou spécifiez les rôles individuellement par leur nom d'affichage."
  type        = list(string)
  default     = []

  validation {
    condition = length(var.included_roles) == 0 || (
      # Si "All" est présent, il doit être seul
      contains(var.included_roles, "All") ? length(var.included_roles) == 1 : true
    )
    error_message = "Si 'All' est utilisé pour inclure tous les rôles, il doit être la seule valeur dans la liste."
  }
}
variable "included_users" {
  description = "La liste des nom à exclure de la règle d'accès conditonnel.  Utiliser le prenom.nom pour les domaines par défaut et admin:prenom.nom pour les domaines admin par défaut. Sinon All"
  type        = list(string)
  default     = ["All"]

  validation {
    condition     = !(contains(var.included_users, "All") && length(var.included_users) > 1)
    error_message = "Si 'All' est utilisé, il doit être la seule valeur dans la liste."
  }
}

##################################################
##### Variables pour le block GRANT CONTROLS #####
##################################################

variable "grant_logical_operator" {
  description = "Opérateur logique"
  type        = string

  validation {
    condition     = contains(["AND", "OR"], var.grant_logical_operator)
    error_message = "La variable doit être 'AND' ou 'OR'."
  }
}

variable "grant_built_in_controls" {
  description = "Liste des contrôles intégrés requis par la politique"
  type        = list(string)
  default     = []

  validation {
    condition = (
      # Si block est présent, il doit être seul
      contains(var.grant_built_in_controls, "block") ? length(var.grant_built_in_controls) == 1 :
      # Sinon, valider les autres contrôles
      alltrue([for control in var.grant_built_in_controls : contains(["mfa", "approvedApplication", "compliantApplication", "compliantDevice", "domainJoinedDevice", "passwordChange"], control)])
    )
    error_message = "Si 'block' est utilisé, il doit être seul. Sinon, utilisez une combinaison de: mfa, approvedApplication, compliantApplication, compliantDevice, domainJoinedDevice, passwordChange."
  }
}


variable "authentication_strength" {
  description = "Nom de la politique 'authentication stregth'. Pour l'utiliser, elle doit être créé par terraform ou utiliser l'une créé par défaut."
  type        = string
  default     = null
}

variable "authentication_strength_list" {
  type = list(object({
    id          = string
    displayName = string
  }))
  default = [
    {
      id          = "/policies/authenticationStrengthPolicies/a8fbd46c-7e88-44a6-be3c-ff9455a7d778"
      displayName = "MFA for Admins"
    },
    {
      id          = "/policies/authenticationStrengthPolicies/b643fded-cedd-47f6-8db8-ab2bf55cd3a0"
      displayName = "Authenticator - Phone Sign-in"
    },
    {
      id          = "/policies/authenticationStrengthPolicies/7fc180ee-c0d1-46b7-ba68-ccfdcd31af6b"
      displayName = "Passkey Only"
    },
    {
      id          = "/policies/authenticationStrengthPolicies/6aedb50f-f1dd-4876-ab5a-f1fb9a650fa7"
      displayName = "Phone Sign-in or Passkey"
    },
    {
      id          = "/policies/authenticationStrengthPolicies/00000000-0000-0000-0000-000000000002"
      displayName = "Multifactor authentication"
    },
    {
      id          = "/policies/authenticationStrengthPolicies/00000000-0000-0000-0000-000000000003"
      displayName = "Passwordless MFA"
    },
    {
      id          = "/policies/authenticationStrengthPolicies/00000000-0000-0000-0000-000000000004"
      displayName = "Phishing-resistant MFA"
    }
  ]
}

####################################################
##### Variables pour le block SESSION CONTROLS #####
####################################################

variable "session_use_conditional_access_app_control" {
  description = "Use conditional access app control"
  type        = string
  default     = null

  validation {
    #condition     = contains(["null", "blockDownloads", "mcasConfigured", "monitorOnly"], var.session_use_conditional_access_app_control)
    condition     = var.session_use_conditional_access_app_control == null ? true : contains(["blockDownloads", "mcasConfigured", "monitorOnly"], var.session_use_conditional_access_app_control)
    error_message = "La valeur doit être l'une des suivantes: null, blockDownloads, mcasConfigured, monitorOnly."
  }
}

variable "session_persistent_browser_mode" {
  description = "Persistent browser mode"
  type        = string
  default     = null

  validation {
    #condition     = contains(["always", "never"], var.session_persistent_browser_mode)
    condition     = var.session_persistent_browser_mode == null ? true : contains(["always", "never"], var.session_persistent_browser_mode)
    error_message = "La valeur doit être l'une des suivantes: always, never."
  }
}

variable "session_sign_in_frequency" {
  description = "Sign-in frequency"
  type        = number
  default     = null
}

variable "session_sign_in_frequency_period" {
  description = "Sign-in frequency period"
  type        = string
  default     = null

  validation {
    #condition     = contains(["hours", "days"], var.session_sign_in_frequency_period)
    condition     = var.session_sign_in_frequency_period == null ? true : contains(["hours", "days"], var.session_sign_in_frequency_period)
    error_message = "La valeur doit être l'une des suivantes: hours, days."
  }
}

variable "session_sign_in_frequency_interval" {
  description = "Sign-in frequency interval"
  type        = string
  default     = "timeBased"

  validation {
    #condition     = contains(["timeBased", "everyTime"], var.session_sign_in_frequency_interval)
    condition     = var.session_sign_in_frequency_interval == null ? true : contains(["timeBased", "everyTime"], var.session_sign_in_frequency_interval)
    error_message = "La valeur doit être l'une des suivantes: timeBased, everyTime."
  }
}

###########################################
##### Variables pour le block DEVICES #####
###########################################

variable "condition_device_filter_mode" {
  description = "Mode du filtre de device (include ou exclude)."
  type        = string
  default     = null

  validation {
    condition     = var.condition_device_filter_mode == null ? true : contains(["include", "exclude"], var.condition_device_filter_mode)
    error_message = "La valeur doit être 'include' ou 'exclude'."
  }
}

variable "condition_device_filter_rule" {
  description = "Règle de filtrage des devices (syntaxe OData)."
  type        = string
  default     = null
}

#################################################
##### Variables pour le block WORKLOAD IDENTITIES #####
#################################################

variable "workload_identities_included_service_principals" {
  description = "Liste des service principals à inclure dans la règle d'accès conditionnel. Peut contenir des noms (display_name), 'All' pour tous les service principals possédés, ou 'ServicePrincipalsInMyTenant' (valeur directe Azure AD)."
  type        = list(string)
  default     = []
}

variable "workload_identities_excluded_service_principals" {
  description = "Liste des service principals à exclure de la règle d'accès conditionnel. Peut contenir des noms (display_name)."
  type        = list(string)
  default     = []
}

variable "workload_identities_filter_mode" {
  description = "Mode du filtre pour les workload identities (include ou exclude)."
  type        = string
  default     = null

  validation {
    condition     = var.workload_identities_filter_mode == null ? true : contains(["include", "exclude"], var.workload_identities_filter_mode)
    error_message = "La valeur doit être 'include' ou 'exclude'."
  }
}

variable "workload_identities_filter_rule" {
  description = "Règle de filtrage des workload identities (syntaxe OData). Example: CustomSecurityAttribute.Applications_WIUsageLocation -eq \"Metallic\""
  type        = string
  default     = null
}
