# =============================================================================
# CE FICHIER A ÉTÉ DIVISÉ EN PLUSIEURS FICHIERS PLUS SPÉCIALISÉS
# =============================================================================
# 
# Les locals ont été réorganisés dans les fichiers suivants :
# - locals-environment.tf : Gestion des environnements, états et domaines
# - locals-users.tf       : Gestion des utilisateurs (inclusions/exclusions)
# - locals-applications.tf : Gestion des applications et détection automatique
# - locals-conditions.tf  : Conditions et logique des blocs conditionnels
# - locals-location.tf    : Gestion des named locations (existant)
# - locals-validations.tf : Validations centralisées pour détecter les conflits
#
# Cette séparation améliore la lisibilité et la maintenabilité du code.
# =============================================================================
