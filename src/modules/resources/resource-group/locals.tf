locals {
  # Déterminer l'ID de la souscription à utiliser
  subscription_id = var.subscription_id != null ? var.subscription_id : (
    var.subscription_name != null ? data.azurerm_subscriptions.search[0].subscriptions[0].subscription_id : null
  )

  # Récupérer les données du resource group (existant ou créé)
  resource_group = var.use_existing ? data.azurerm_resource_group.existing[0] : azurerm_resource_group.this[0]
}
