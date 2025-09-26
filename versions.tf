############################################
# Terraform & Provider Version Constraints
############################################

terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
  }
}

############################################
# Provider Configurations
############################################

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azuread" {}