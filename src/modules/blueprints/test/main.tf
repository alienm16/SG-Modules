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
resource "azuread_service_principal" "ServicePrincipal" {
  client_id                    = azuread_application.AppRegistration.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]

  depends_on = [
    azuread_application.AppRegistration
  ]

}


# Configuration des Federated Credentials pour les branches
resource "azuread_application_federated_identity_credential" "github_branches" {
  application_id = azuread_application.AzureTerraformPreReq-App.id
  display_name   = "github-${var.github_repository}-${var.github_branch}-${var.tenant}"
  description    = "GitHub Actions credential for ${var.github_organization}/${var.github_repository} on branch ${var.github_branch} - ENV: ${upper(var.tenant)}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_organization}/${var.github_repository}:ref:refs/heads/${var.github_branch}"
}

# Configuration des Federated Credentials pour les Pull Requests
resource "azuread_application_federated_identity_credential" "github_pull_requests" {
  application_id = azuread_application.AzureTerraformPreReq-App.id
  display_name   = "github-${var.github_repository}-pull-request-${var.tenant}"
  description    = "GitHub Actions credential for ${var.github_organization}/${var.github_repository} pull requests - ENV: ${upper(var.tenant)}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_organization}/${var.github_repository}:pull_request"
}

