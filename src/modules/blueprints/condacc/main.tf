resource "azuread_conditional_access_policy" "this" {
  # Validation finale des configurations avant création de la ressource
  depends_on = [local.validation_check]

  display_name = var.display_name
  state        = local.final_state
  conditions {
    client_app_types              = sort([for type in var.condition_client_app_types : type])
    insider_risk_levels           = var.condition_insider_risk_levels != null ? var.condition_insider_risk_levels : null
    service_principal_risk_levels = var.condition_service_principal_risk_levels != null ? [for risk in var.condition_service_principal_risk_levels : risk] : []
    sign_in_risk_levels           = var.condition_sign_in_risk_levels != null ? [for risk in var.condition_sign_in_risk_levels : risk] : []
    user_risk_levels              = var.condition_user_risk_levels != null ? [for risk in var.condition_user_risk_levels : risk] : []
    applications {
      excluded_applications = concat(
        # Apps spéciales (MicrosoftAdminPortals, Office365) - comportement original
        local.excluded_special_apps,
        # Apps récupérées par nom (comportement original) - CHANGEMENT ICI
        [for sp in data.azuread_service_principal.excluded_applications : sp.client_id],
        # Client_ids passés directement (nouveau comportement pour fake apps)
        local.excluded_client_ids
      )
      included_applications = local.use_included_user_actions ? null : (
        local.use_all_apps ? ["All"] :
        local.use_none_apps ? ["None"] :
        concat(
          # Apps spéciales (MicrosoftAdminPortals, Office365) - comportement original
          local.included_special_apps,
          # Apps récupérées par nom (comportement original) - CHANGEMENT ICI
          [for sp in data.azuread_service_principal.included_applications : sp.client_id],
          # Client_ids passés directement (nouveau comportement pour fake apps)
          local.included_client_ids
        )
      )
      included_user_actions = local.use_included_user_actions ? var.included_user_actions : null

    }
    # Bloc users - requis même pour workload identities
    users {
      # Groupes exclus - Utilisation directe de var.excluded_groups (object_id uniquement)
      excluded_groups = local.use_workload_identities_block ? [] : var.excluded_groups

      excluded_roles = local.use_workload_identities_block ? [] : [for role in data.azuread_directory_roles.roles.roles : role.template_id if contains(var.excluded_roles, role.display_name)]

      excluded_users = local.use_workload_identities_block ? [] : concat(
        # Comptes breakglass (toujours exclus)
        [for id in data.azuread_users.breakglass.object_ids : id],
        # Valeurs spéciales comme "GuestsOrExternalUsers"
        local.excluded_special_users,
        # Utilisateurs avec UPNs générés dynamiquement
        [for upn in local.excluded_final_upns : data.azuread_user.excluded_users[upn].object_id]
      )

      # Groupes inclus - Utilisation directe de var.included_groups (object_id uniquement)
      included_groups = local.use_workload_identities_block ? [] : var.included_groups

      included_roles = local.use_workload_identities_block ? [] : [for role in data.azuread_directory_roles.roles.roles : role.template_id if contains(local.final_included_roles, role.display_name)]
      included_users = local.use_workload_identities_block ? ["None"] : (
        # Si on a des utilisateurs spécifiques ou des valeurs spéciales, les utiliser
        length(local.included_special_users) > 0 || length(local.included_final_upns) > 0 ? concat(
          # Valeurs spéciales (All ou GuestsOrExternalUsers)
          local.included_special_users,
          # Utilisateurs avec UPNs générés dynamiquement (seulement si All n'est pas présent)
          [for upn in local.included_final_upns : data.azuread_user.included_users[upn].object_id]
          ) : (
          # Si pas d'utilisateurs spécifiques mais qu'on a des groupes ou rôles inclus, utiliser une liste vide
          length(var.included_groups) > 0 || length(var.included_roles) > 0 ? [] : ["All"]
        )
      )
    }

    # Bloc platforms COMPLÈTEMENT CONDITIONNEL avec dynamic
    dynamic "platforms" {
      for_each = local.use_platforms_block ? [1] : []
      content {
        included_platforms = local.use_included_platforms ? [for platform in var.condition_included_platforms : platform] : []
        excluded_platforms = local.use_excluded_platforms ? [for platform in var.condition_excluded_platforms : platform] : []
      }
    }

    dynamic "locations" {
      for_each = local.use_locations_block ? [1] : []
      content {
        included_locations = local.validated_final_included_locations # ← Changement ici
        excluded_locations = local.validated_final_excluded_locations # ← Changement ici
      }
    }

    # Bloc devices COMPLÈTEMENT CONDITIONNEL avec dynamic
    dynamic "devices" {
      for_each = local.use_devices_block ? [1] : []
      content {
        filter {
          mode = var.condition_device_filter_mode
          rule = var.condition_device_filter_rule
        }
      }
    }

    # Bloc client_applications pour les workload identities (service principals) - DANS conditions
    dynamic "client_applications" {
      for_each = local.use_workload_identities_block ? [1] : []
      content {
        included_service_principals = local.use_all_service_principals ? ["ServicePrincipalsInMyTenant"] : [
          for sp in data.azuread_service_principal.included_workload_identities : sp.object_id
        ]
        excluded_service_principals = [
          for sp in data.azuread_service_principal.excluded_workload_identities : sp.object_id
        ]

        # Le bloc filter est conditionnel - seulement si les variables sont définies
        dynamic "filter" {
          for_each = local.use_workload_filter ? [1] : []
          content {
            mode = var.workload_identities_filter_mode
            rule = var.workload_identities_filter_rule
          }
        }
      }
    }
  }

  # Bloc grant_controls conditionnel - seulement si nécessaire
  dynamic "grant_controls" {
    for_each = (length(var.grant_built_in_controls) > 0 || var.authentication_strength != null && var.authentication_strength != "") ? [1] : []
    content {
      authentication_strength_policy_id = var.authentication_strength != null && var.authentication_strength != "" ? (
        startswith(var.authentication_strength, "/policies/") ? var.authentication_strength :
        lookup({ for policy in var.authentication_strength_list : policy.displayName => policy.id }, var.authentication_strength, null)
      ) : null
      built_in_controls = length(var.grant_built_in_controls) == 0 ? null : (length(
        [for control in var.grant_built_in_controls : control if control == "block"]) > 0 ? ["block"] : concat(
      [for control in var.grant_built_in_controls : control if control != "block"]))
      custom_authentication_factors = []
      operator                      = var.grant_logical_operator
      terms_of_use                  = []
    }
  }

  session_controls {
    application_enforced_restrictions_enabled = false
    disable_resilience_defaults               = false
    cloud_app_security_policy                 = var.session_use_conditional_access_app_control != null ? var.session_use_conditional_access_app_control : null
    persistent_browser_mode                   = var.session_persistent_browser_mode != null ? var.session_persistent_browser_mode : null
    sign_in_frequency                         = var.session_sign_in_frequency != null ? var.session_sign_in_frequency : null
    sign_in_frequency_period                  = var.session_sign_in_frequency_period != null ? var.session_sign_in_frequency_period : null
    sign_in_frequency_interval                = var.session_sign_in_frequency_interval != null ? var.session_sign_in_frequency_interval : null
    #sign_in_frequency_authentication_type     = "primaryAndSecondaryAuthentication"
  }
}
