output "resource_group_name" {
  description = "Nom du resource group"
  value       = local.resource_group.name
}

output "resource_group_id" {
  description = "ID du resource group"
  value       = local.resource_group.id
}

output "location" {
  description = "Région du resource group"
  value       = local.resource_group.location
}

output "tags" {
  description = "Tags du resource group"
  value       = local.resource_group.tags
}