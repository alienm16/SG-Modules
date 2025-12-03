# Module Blueprint: Test

## Description

Ce module blueprint permet de créer une application Azure AD (App Registration) avec les capacités suivantes :
- **Application Registration** avec Federated Identity Credentials pour GitHub Actions
- **Resource Group** (création ou utilisation d'un existant)
- **Storage Account** avec conteneurs blob et file shares

## Fonctionnalités

### 1. Application Registration (Obligatoire)
- Création d'une App Registration Azure AD
- Création d'un Service Principal
- Configuration de Federated Identity Credentials pour :
  - GitHub branches
  - GitHub Pull Requests

### 2. Resource Group (Optionnel)
- Création d'un nouveau Resource Group
- Utilisation d'un Resource Group existant
- Configuration des tags

### 3. Storage Account (Optionnel)
- Création d'un Storage Account
- Support de multiples tiers et types de réplication
- Configuration de sécurité (HTTPS, TLS, accès réseau)
- Création de conteneurs blob
- Création de file shares

## Variables

### Application Registration (Requis)
| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `app_name` | string | - | Nom de l'application registration |
| `app_description` | string | - | Description de l'application |
| `github_organization` | string | "beneva-int" | Organisation GitHub |
| `github_repository` | string | - | Nom du repository GitHub |
| `github_branch` | string | - | Branche principale GitHub |
| `tenant` | string | "prod" | Environnement (dev/lab/prod) |
| `auto_grant_admin_consent` | bool | true | Consentement automatique |

### Resource Group (Optionnel)
| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `create_resource_group` | bool | false | Créer un resource group |
| `resource_group_name` | string | null | Nom du resource group |
| `location` | string | "canadacentral" | Région Azure (canadacentral/canadaeast) |
| `use_existing_rg` | bool | false | Utiliser un RG existant |
| `tags` | map(string) | {} | Tags à appliquer |

### Storage Account (Optionnel)
| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `create_storage_account` | bool | false | Créer un storage account |
| `storage_account_name` | string | null | Nom du storage account (3-24 caractères) |
| `use_existing_storage` | bool | false | Utiliser un storage existant |
| `storage_account_tier` | string | "Standard" | Tier (Standard/Premium) |
| `storage_account_replication_type` | string | "LRS" | Réplication (LRS/GRS/RAGRS/ZRS/GZRS/RAGZRS) |
| `storage_account_kind` | string | "StorageV2" | Type de storage account |
| `storage_access_tier` | string | "Hot" | Access tier (Hot/Cool) |
| `storage_https_traffic_only_enabled` | bool | true | Forcer HTTPS uniquement |
| `storage_min_tls_version` | string | "TLS1_2" | Version minimale de TLS |
| `storage_public_network_access_enabled` | bool | true | Activer l'accès réseau public |
| `storage_shared_access_key_enabled` | bool | true | Activer les clés d'accès partagées |
| `storage_containers` | list(object) | [] | Liste des conteneurs blob |
| `storage_file_shares` | list(object) | [] | Liste des file shares |

## Outputs

### Application Registration
| Output | Description |
|--------|-------------|
| `application_id` | ID de l'application registration |
| `application_object_id` | Object ID de l'application |
| `client_id` | Client ID de l'application |
| `service_principal_id` | ID du service principal |
| `service_principal_object_id` | Object ID du service principal |

### Resource Group
| Output | Description |
|--------|-------------|
| `resource_group_name` | Nom du resource group |
| `resource_group_id` | ID du resource group |
| `location` | Région du resource group |

### Storage Account
| Output | Description |
|--------|-------------|
| `storage_account_id` | ID du storage account |
| `storage_account_name` | Nom du storage account |
| `primary_blob_endpoint` | Endpoint principal pour les blobs |
| `primary_file_endpoint` | Endpoint principal pour les files |
| `primary_access_key` | Clé d'accès principale (sensitive) |
| `primary_connection_string` | Chaîne de connexion (sensitive) |
| `containers` | Map des conteneurs créés |
| `file_shares` | Map des file shares créés |

## Exemples d'utilisation

### Exemple 1 : Application Registration simple
```hcl
module "simple_app" {
  source = "git::https://github.com/alienm16/SG-Modules.git//src//modules/blueprints/test?ref=main"
  
  app_name          = "SG-MyApp"
  app_description   = "Mon application de test"
  github_repository = "SG-Terraform"
  github_branch     = "main"
  tenant            = "dev"
}
```

### Exemple 2 : Application avec Resource Group et Storage Account
```hcl
module "app_with_storage" {
  source = "git::https://github.com/alienm16/SG-Modules.git//src//modules/blueprints/test?ref=main"
  
  # Application
  app_name          = "SG-MyApp-WithStorage"
  app_description   = "Application avec stockage"
  github_repository = "SG-Terraform"
  github_branch     = "main"
  tenant            = "prod"
  
  # Resource Group
  create_resource_group = true
  resource_group_name   = "rg-myapp-prod"
  location              = "canadacentral"
  
  # Storage Account
  create_storage_account           = true
  storage_account_name             = "stgmyappprod"
  storage_account_tier             = "Standard"
  storage_account_replication_type = "LRS"
  storage_public_network_access_enabled = false
  
  # Conteneurs
  storage_containers = [
    {
      name                  = "data"
      container_access_type = "private"
    },
    {
      name                  = "backups"
      container_access_type = "private"
    }
  ]
  
  # File shares
  storage_file_shares = [
    {
      name  = "configs"
      quota = 100
    }
  ]
  
  # Tags
  tags = {
    Environment = "Production"
    Project     = "MyApp"
    ManagedBy   = "Terraform"
  }
}
```

### Exemple 3 : Application avec Resource Group existant
```hcl
module "app_existing_rg" {
  source = "git::https://github.com/alienm16/SG-Modules.git//src//modules/blueprints/test?ref=main"
  
  # Application
  app_name          = "SG-MyApp"
  app_description   = "Application dans RG existant"
  github_repository = "SG-Terraform"
  github_branch     = "main"
  tenant            = "prod"
  
  # Resource Group existant
  create_resource_group = true
  resource_group_name   = "rg-existing-prod"
  location              = "canadacentral"
  use_existing_rg       = true  # Important !
  
  # Storage Account
  create_storage_account = true
  storage_account_name   = "stgmyappprod"
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Notes importantes

1. **Resource Group** :
   - Si `create_resource_group = false`, les variables de RG ne sont pas nécessaires
   - Si `use_existing_rg = true`, le RG doit déjà exister

2. **Storage Account** :
   - Le nom doit être unique dans Azure (3-24 caractères alphanumériques en minuscules)
   - Si un RG est créé, le storage account sera créé dedans automatiquement
   - Si `create_storage_account = false`, toutes les variables storage sont ignorées

3. **Dépendances** :
   - Le Storage Account dépend du Resource Group
   - Si vous créez les deux, l'ordre est géré automatiquement

## Prérequis

- Terraform >= 1.0
- Provider AzureRM >= 3.0
- Provider AzureAD >= 2.0
- Droits suffisants dans Azure AD et Azure

## Licence

Propriétaire : Beneva
