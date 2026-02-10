output "subscription_id" {
  description = "ID de la souscription Azure utilisée"
  value       = module.resource_group.subscription_id
}

output "storage_account_id" {
  description = "ID du storage account"
  value       = local.storage_account.id
}

output "storage_account_name" {
  description = "Nom du storage account"
  value       = local.storage_account.name
}

output "primary_blob_endpoint" {
  description = "Endpoint principal pour les blobs"
  value       = local.storage_account.primary_blob_endpoint
}

output "primary_file_endpoint" {
  description = "Endpoint principal pour les files"
  value       = local.storage_account.primary_file_endpoint
}

output "primary_access_key" {
  description = "Clé d'accès principale"
  value       = local.storage_account.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "Chaîne de connexion principale"
  value       = local.storage_account.primary_connection_string
  sensitive   = true
}

output "resource_group_name" {
  description = "Nom du resource group"
  value       = module.resource_group.resource_group_name
}

output "location" {
  description = "Région du storage account"
  value       = local.storage_account.location
}

output "containers" {
  description = "Conteneurs créés"
  value       = { for k, v in azurerm_storage_container.containers : k => v.name }
}

output "file_shares" {
  description = "File shares créés"
  value       = { for k, v in azurerm_storage_share.shares : k => v.name }
}
