# ====================================
# Resource Group Outputs
# ====================================
output "resource_group_name" {
  description = "Nom du resource group"
  value       = var.resource_group_name != null ? module.resource_group[0].resource_group_name : null
}

output "resource_group_id" {
  description = "ID du resource group"
  value       = var.resource_group_name != null ? module.resource_group[0].resource_group_id : null
}

output "location" {
  description = "Région du resource group"
  value       = var.resource_group_name != null ? module.resource_group[0].location : null
}

# ====================================
# Storage Account Outputs
# ====================================
output "storage_account_id" {
  description = "ID du storage account"
  value       = var.storage_account_name != null ? module.storage_account[0].storage_account_id : null
}

output "storage_account_name" {
  description = "Nom du storage account"
  value       = var.storage_account_name != null ? module.storage_account[0].storage_account_name : null
}

output "primary_blob_endpoint" {
  description = "Endpoint principal pour les blobs"
  value       = var.storage_account_name != null ? module.storage_account[0].primary_blob_endpoint : null
}

output "primary_file_endpoint" {
  description = "Endpoint principal pour les files"
  value       = var.storage_account_name != null ? module.storage_account[0].primary_file_endpoint : null
}

output "primary_access_key" {
  description = "Clé d'accès principale du storage account"
  value       = var.storage_account_name != null ? module.storage_account[0].primary_access_key : null
  sensitive   = true
}

output "primary_connection_string" {
  description = "Chaîne de connexion principale du storage account"
  value       = var.storage_account_name != null ? module.storage_account[0].primary_connection_string : null
  sensitive   = true
}

output "containers" {
  description = "Conteneurs blob créés"
  value       = var.storage_account_name != null ? module.storage_account[0].containers : {}
}

output "file_shares" {
  description = "File shares créés"
  value       = var.storage_account_name != null ? module.storage_account[0].file_shares : {}
}

# ====================================
# Application Registration Outputs
# ====================================
output "application_id" {
  description = "ID de l'application registration"
  value       = azuread_application.AppRegistration.id
}

output "application_object_id" {
  description = "Object ID de l'application registration"
  value       = azuread_application.AppRegistration.object_id
}

output "client_id" {
  description = "Client ID de l'application registration"
  value       = azuread_application.AppRegistration.client_id
}

output "service_principal_id" {
  description = "ID du service principal"
  value       = azuread_service_principal.ServicePrincipal.id
}

output "service_principal_object_id" {
  description = "Object ID du service principal"
  value       = azuread_service_principal.ServicePrincipal.object_id
}

# ====================================
# RBAC Role Assignments Outputs
# ====================================
output "resource_group_reader_role_assignment_id" {
  description = "ID de l'attribution du rôle Reader sur le Resource Group"
  value       = var.resource_group_name != null ? azurerm_role_assignment.resource_group_reader[0].id : null
}

output "storage_contributor_role_assignment_id" {
  description = "ID de l'attribution du rôle Storage Blob Data Contributor sur le Storage Account"
  value       = var.storage_account_name != null ? azurerm_role_assignment.terraform_state_contributor[0].id : null
}

