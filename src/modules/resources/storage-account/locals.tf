locals {
  # Configuration des sites prédéfinis avec leurs IPs respectives
  predefined_sites = {
    zscaler = {
      name = "Zscaler"
      ips  = ["165.225.28.238"]
    }
    beneva = {
      name = "Beneva"
      ips  = ["204.19.214.212/22", "45.33.23.145"]
    }
    aws_beneva = {
      name = "AWS Beneva"
      ips  = ["3.99.98.45.21", "15.34.65.78"]
    }
  }

  # Validation : si des IPs personnalisées sont fournies mais non autorisées, lever une erreur
  validate_custom_ip = var.storage_network_rules_allow_custom_ip == false && length(var.storage_network_rules_ip_rules) > 0 ? tobool("ERROR: storage_network_rules_ip_rules est verrouillé. Contactez l'administrateur pour débloquer storage_network_rules_allow_custom_ip=true ou utilisez storage_network_rules_allowed_sites avec les sites prédéfinis (zscaler, beneva, aws_beneva).") : true

  # Concaténer les IPs des sites sélectionnés ou utiliser les IPs personnalisées
  resolved_ip_rules = length(var.storage_network_rules_allowed_sites) > 0 ? flatten([
    for site in var.storage_network_rules_allowed_sites :
    local.predefined_sites[site].ips
  ]) : (var.storage_network_rules_allow_custom_ip ? var.storage_network_rules_ip_rules : [])

  # Obj storage account
  storage_account = var.use_existing_storage ? data.azurerm_storage_account.existing[0] : azurerm_storage_account.this[0]
}
