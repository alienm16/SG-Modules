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