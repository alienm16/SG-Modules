# Application Registration Variables
variable "app_name" {
  description = "Nom de l'application registration"
  type        = string
}

variable "app_description" {
  description = "Description de l'application registration et service principal"
  type        = string
}

variable "tenant" {
  type        = string
  default     = "prod"
}

# Consentement automatique
variable "auto_grant_admin_consent" {
  description = "Accorder automatiquement le consentement administrateur pour les permissions Microsoft Graph"
  type        = bool
  default     = true # Par défaut activé (sera désactivé en prod via GitHub Actions)

  validation {
    condition     = can(tobool(var.auto_grant_admin_consent))
    error_message = "La valeur doit être true ou false."
  }

}