# Création de l'application registration AVEC les permissions (méthode qui fonctionne)
resource "azuread_application" "AppRegistration" {
  display_name     = var.app_name
  description      = var.app_description
  prevent_duplicate_names = true
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"

  # Configuration API
  api {
    mapped_claims_enabled          = false
    requested_access_token_version = 2
  }

}


# Création du service principal
#resource "azuread_service_principal" "ServicePrincipal" {
#  client_id                    = azuread_application.AppRegistration.client_id
#  app_role_assignment_required = false
#  owners                       = [data.azuread_client_config.current.object_id]

#  depends_on = [
#    azuread_application.AppRegistration,
#    time_sleep.wait_30_seconds
#  ]

#}


