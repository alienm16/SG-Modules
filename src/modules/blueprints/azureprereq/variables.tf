# ====================================
# Subscription Variables
# ====================================
variable "subscription_id" {
  description = "ID de la souscription Azure (optionnel). Si non fourni, utilise la souscription par défaut du provider"
  type        = string
  default     = null
}

variable "subscription_name" {
  description = "Nom de la souscription Azure (optionnel). Ignoré si subscription_id est fourni"
  type        = string
  default     = null
}

# ====================================
# Resource Group Variables
# ====================================
variable "resource_group_name" {
  description = "Nom du resource group à utiliser ou créer (si null, pas de RG géré par ce module)"
  type        = string
  default     = null
}

variable "location" {
  description = "Région Azure pour les ressources"
  type        = string
  default     = "canadacentral"

  validation {
    condition     = contains(["canadacentral", "canadaeast"], var.location)
    error_message = "La région doit être 'canadacentral' ou 'canadaeast'."
  }
}

variable "use_existing_rg" {
  description = "Si true, utilise un RG existant. Si false, crée un nouveau RG (nécessite resource_group_name)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags à appliquer aux ressources"
  type        = map(string)
  default     = {}
}

# ====================================
# Storage Account Variables
# ====================================
variable "storage_account_name" {
  description = "Nom du storage account à utiliser ou créer (si null, pas de storage account géré par ce module)"
  type        = string
  default     = null

  validation {
    condition     = var.storage_account_name == null || can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Le nom du storage account doit contenir entre 3 et 24 caractères alphanumériques en minuscules uniquement."
  }
}

variable "use_existing_storage" {
  description = "Si true, utilise un storage existant. Si false, crée un nouveau storage account (nécessite storage_account_name)"
  type        = bool
  default     = false
}

variable "storage_account_tier" {
  description = "Tier du storage account"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Le tier doit être 'Standard' ou 'Premium'."
  }
}

variable "storage_account_replication_type" {
  description = "Type de réplication"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account_replication_type)
    error_message = "Le type de réplication doit être LRS, GRS, RAGRS, ZRS, GZRS ou RAGZRS."
  }
}

variable "storage_account_kind" {
  description = "Type de storage account"
  type        = string
  default     = "StorageV2"

  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.storage_account_kind)
    error_message = "Le kind doit être BlobStorage, BlockBlobStorage, FileStorage, Storage ou StorageV2."
  }
}

variable "storage_access_tier" {
  description = "Access tier pour le storage account"
  type        = string
  default     = "Hot"

  validation {
    condition     = contains(["Hot", "Cool"], var.storage_access_tier)
    error_message = "L'access tier doit être 'Hot' ou 'Cool'."
  }
}

variable "storage_https_traffic_only_enabled" {
  description = "Forcer le trafic HTTPS uniquement"
  type        = bool
  default     = true
}

variable "storage_min_tls_version" {
  description = "Version minimale de TLS"
  type        = string
  default     = "TLS1_2"

  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.storage_min_tls_version)
    error_message = "La version TLS doit être TLS1_0, TLS1_1 ou TLS1_2."
  }
}

variable "storage_public_network_access_enabled" {
  description = "Activer l'accès réseau public"
  type        = bool
  default     = false
}

variable "storage_shared_access_key_enabled" {
  description = "Activer l'accès par clé partagée"
  type        = bool
  default     = false
}

variable "storage_network_rules_enabled" {
  description = "Activer les règles de firewall réseau sur le storage account"
  type        = bool
  default     = false
}

variable "storage_network_rules_default_action" {
  description = "Action par défaut du firewall (Allow ou Deny)"
  type        = string
  default     = "Deny"

  validation {
    condition     = contains(["Allow", "Deny"], var.storage_network_rules_default_action)
    error_message = "L'action doit être 'Allow' ou 'Deny'."
  }
}

variable "storage_network_rules_ip_rules" {
  description = "Liste des IP publiques autorisées (ex: ['20.12.34.56', '40.50.60.0/24'])"
  type        = list(string)
  default     = []
}

variable "storage_network_rules_virtual_network_subnet_ids" {
  description = "Liste des IDs de subnets Azure autorisés"
  type        = list(string)
  default     = []
}

variable "storage_network_rules_bypass" {
  description = "Services Azure autorisés à bypasser le firewall"
  type        = list(string)
  default     = ["AzureServices"]
}

variable "storage_containers" {
  description = "Liste des conteneurs blob à créer"
  type = list(object({
    name                  = string
    container_access_type = optional(string, "private")
  }))
  default = []
}

variable "storage_file_shares" {
  description = "Liste des file shares à créer"
  type = list(object({
    name  = string
    quota = optional(number, 50)
  }))
  default = []
}

# ====================================
# Application Registration Variables
# ====================================
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
  type    = string
  default = "prod"
}

# GitHub Variables
variable "github_organization" {
  description = "Organisation GitHub"
  type        = string
  default     = "beneva-int"
}

variable "github_repository" {
  description = "Nom du repository GitHub"
  type        = string
}

variable "github_branch" {
  description = "Branche principale GitHub pour cet environnement"
  type        = string
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

# Permissions Microsoft Graph
variable "graph_application_permissions" {
  description = "Liste des permissions d'application Microsoft Graph (ex: ['User.Read.All', 'Group.ReadWrite.All'])"
  type        = list(string)
  default     = []
}
