variable "storage_account_name" {
  description = "Nom du storage account (3-24 caractères alphanumériques en minuscules)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Le nom du storage account doit contenir entre 3 et 24 caractères alphanumériques en minuscules uniquement."
  }
}

variable "resource_group_name" {
  description = "Nom du resource group"
  type        = string
}

variable "location" {
  description = "Région Azure (canadacentral ou canadaeast uniquement)"
  type        = string
  default     = "canadacentral"

  validation {
    condition     = contains(["canadacentral", "canadaeast"], var.location)
    error_message = "La région doit être 'canadacentral' ou 'canadaeast'."
  }
}

variable "use_existing_rg" {
  description = "Utiliser un resource group existant"
  type        = bool
  default     = false
}

variable "use_existing_storage" {
  description = "Utiliser un storage account existant"
  type        = bool
  default     = false
}

variable "account_tier" {
  description = "Tier du storage account"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Le tier doit être 'Standard' ou 'Premium'."
  }
}

variable "account_replication_type" {
  description = "Type de réplication"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Le type de réplication doit être LRS, GRS, RAGRS, ZRS, GZRS ou RAGZRS."
  }
}

variable "account_kind" {
  description = "Type de storage account"
  type        = string
  default     = "StorageV2"

  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "Le kind doit être BlobStorage, BlockBlobStorage, FileStorage, Storage ou StorageV2."
  }
}

variable "access_tier" {
  description = "Access tier pour le storage account"
  type        = string
  default     = "Hot"

  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "L'access tier doit être 'Hot' ou 'Cool'."
  }
}

variable "https_traffic_only_enabled" {
  description = "Forcer le trafic HTTPS uniquement"
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "Version minimale de TLS"
  type        = string
  default     = "TLS1_2"

  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "La version TLS doit être TLS1_0, TLS1_1 ou TLS1_2."
  }
}

variable "public_network_access_enabled" {
  description = "Activer l'accès réseau public"
  type        = bool
  default     = true
}

variable "allow_nested_items_to_be_public" {
  description = "Permettre l'accès public aux blobs (deprecated, utilisez public_network_access_enabled)"
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Activer l'accès par clé partagée"
  type        = bool
  default     = true
}

variable "containers" {
  description = "Liste des conteneurs à créer"
  type = list(object({
    name                  = string
    container_access_type = optional(string, "private")
  }))
  default = []
}

variable "file_shares" {
  description = "Liste des file shares à créer"
  type = list(object({
    name  = string
    quota = optional(number, 50)
  }))
  default = []
}

variable "tags" {
  description = "Tags à appliquer aux ressources"
  type        = map(string)
  default     = {}
}