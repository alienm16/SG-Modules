# Récupération des informations du tenant Azure AD actuel
data "azuread_client_config" "current" {}

# Récupération des informations du client Azure RM actuel
data "azurerm_client_config" "current" {}

# Récupération du service principal Microsoft Graph
data "azuread_service_principal" "microsoft_graph" {
  client_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
}