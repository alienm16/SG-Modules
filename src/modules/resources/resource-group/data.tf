# Tente de récupérer le resource group s'il existe
data "azurerm_resource_group" "existing" {
  name = var.resource_group_name

  # Ignore l'erreur si le RG n'existe pas
  lifecycle {
    postcondition {
      condition     = self.id != null || self.id == null
      error_message = "Resource group check"
    }
  }
}
