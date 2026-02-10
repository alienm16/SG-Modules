# ====================================
# Locals pour Microsoft Graph Permissions
# ====================================

locals {
  # Créer un map de permissions demandées pour faciliter la recherche
  requested_permissions_map = {
    for permission in var.graph_application_permissions :
    permission => permission
  }

  # Filtrer les app_roles du service principal Microsoft Graph pour ne garder que celles demandées
  required_application_permissions = [
    for app_role in data.azuread_service_principal.microsoft_graph.app_roles :
    {
      id   = app_role.id
      type = "Role"
    }
    if contains(var.graph_application_permissions, app_role.value)
  ]
}