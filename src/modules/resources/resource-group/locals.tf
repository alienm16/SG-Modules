locals {
  # Détermine quelle ressource utiliser selon le scénario
  resource_group = (
    var.use_existing && var.manage_tags ? azurerm_resource_group.managed_existing[0] :
    var.use_existing ? data.azurerm_resource_group.existing[0] :
    azurerm_resource_group.this[0]
  )
}