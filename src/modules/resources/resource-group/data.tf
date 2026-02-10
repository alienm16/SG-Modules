# Récupération de la souscription par nom (si fourni)
data "azurerm_subscriptions" "search" {
  count = var.subscription_name != null && var.subscription_id == null ? 1 : 0

  display_name_contains = var.subscription_name
}

# Récupération du resource group existant
data "azurerm_resource_group" "existing" {
  count = var.use_existing ? 1 : 0
  name  = var.resource_group_name
}
