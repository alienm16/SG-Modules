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
  description = "Nom du resource group à utiliser ou créer"
  type        = string
}

variable "location" {
  description = "Région Azure pour le resource group (requis si create_if_not_exists = true)"
  type        = string
  default     = "canadacentral"
}

variable "tags" {
  description = "Tags à appliquer au resource group"
  type        = map(string)
  default     = {}
}

variable "use_existing" {
  description = "Utiliser un resource group existant (true) ou créer un nouveau (false)"
  type        = bool
  default     = false
}
