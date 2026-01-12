# =============================================================================
# GESTION DES GROUPES - LE MODULE ACCEPTE UNIQUEMENT DES OBJECT_ID
# =============================================================================
# IMPORTANT: Depuis la v2.3.0, le module accepte UNIQUEMENT des object_id (UUID)
# pour les groupes inclus et exclus. Les display_name ne sont plus supportés.
#
# POURQUOI CE CHANGEMENT ?
# - Évite les dépendances circulaires avec les data sources
# - Élimine les erreurs "for_each will be known only after apply"
# - Améliore les performances (pas de lookups API répétés)
# - Simplifie la logique du module
#
# UTILISATION :
# Tous les lookups de groupes doivent être faits AVANT d'appeler le module,
# dans votre projet principal (ex: data_groups_prod.tf).
#
# Exemples :
#   excluded_groups = [
#     local.groups.CLD-CondAcc-TF-Exclusion_302,        # depuis terraform
#     azuread_group.mon_groupe.object_id,               # ressource directe
#     data.azuread_group.groupe_existant[0].object_id   # depuis data source
#   ]
# =============================================================================

# Note: Ce fichier est conservé pour la structure mais ne contient plus de logique.
# Les groupes sont utilisés directement depuis var.excluded_groups et var.included_groups.
