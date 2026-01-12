output "id" {
  value       = azuread_conditional_access_policy.this.id
  description = "ID de la règle d'accès conditionnel"
}

output "display_name" {
  value       = azuread_conditional_access_policy.this.display_name
  description = "Nom d'affichage de la règle d'accès conditionnel"
}

output "state" {
  value       = azuread_conditional_access_policy.this.state
  description = "État actuel de la règle d'accès conditionnel"
}

output "tenant_environment" {
  value       = var.tenant
  description = "Environnement du tenant pour cette règle"
}
