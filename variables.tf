############################################
# Core Configuration
############################################
variable "location" {
  type        = string
  description = "The Azure location where resources will be deployed"
  default     = "East US"
}

variable "prefix" {
  type        = string
  description = "Prefix for resource names (max 4 characters)"
  validation {
    condition     = length(var.prefix) <= 4 && lower(var.prefix) == var.prefix
    error_message = "The prefix value must be lowercase and <= 4 characters."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}

############################################
# Resource Group Configuration
############################################
variable "create_resource_groups" {
  type        = bool
  description = "Whether to create new resource groups or use existing ones"
  default     = true
}

variable "shared_services_rg_name" {
  type        = string
  description = "Name of the resource group for shared services (Storage, Key Vault, etc.)"
}

variable "avd_services_rg_name" {
  type        = string
  description = "Name of the resource group for AVD control plane resources"
}

variable "session_hosts_rg_name" {
  type        = string
  description = "Name of the resource group for session host VMs"
}

############################################
# Networking Configuration
############################################
variable "use_existing_network" {
  type        = bool
  description = "Whether to use an existing virtual network"
  default     = true
}

variable "existing_vnet_name" {
  type        = string
  description = "Name of the existing virtual network"
  default     = ""
}

variable "existing_vnet_rg_name" {
  type        = string
  description = "Name of the resource group containing the existing virtual network"
  default     = ""
}

variable "existing_subnet_name" {
  type        = string
  description = "Name of the existing subnet for session hosts"
  default     = ""
}

############################################
# Log Analytics Configuration
############################################
variable "log_analytics_workspace_name" {
  type        = string
  description = "Name of the Log Analytics workspace"
}

variable "log_analytics_workspace_sku" {
  type        = string
  description = "SKU for the Log Analytics workspace"
  default     = "PerGB2018"
}

variable "log_analytics_retention_in_days" {
  type        = number
  description = "Number of days to retain logs"
  default     = 30
}

############################################
# Key Vault Configuration
############################################
variable "key_vault_name" {
  type        = string
  description = "Name of the Key Vault"
}

variable "key_vault_sku" {
  type        = string
  description = "SKU for the Key Vault"
  default     = "standard"
}

############################################
# Azure Image Builder Configuration
############################################
variable "enable_image_builder" {
  type        = bool
  description = "Whether to create Azure Image Builder resources"
  default     = false
}

variable "aib_api_version" {
  type        = string
  description = "API version for Azure Image Builder"
  default     = "2022-02-14"
}

variable "aib_build_timeout" {
  type        = number
  description = "Build timeout in minutes for Azure Image Builder"
  default     = 120
}

variable "aib_vm_size" {
  type        = string
  description = "VM size for Azure Image Builder"
  default     = "Standard_D2s_v3"
}

############################################
# Compute Gallery Configuration
############################################
variable "compute_gallery_name" {
  type        = string
  description = "Name of the Azure Compute Gallery"
}

variable "image_definition_name" {
  type        = string
  description = "Name of the image definition in the compute gallery"
}

variable "image_publisher" {
  type        = string
  description = "Publisher for the custom image definition"
  default     = "MicrosoftWindowsDesktop"
}

variable "image_offer" {
  type        = string
  description = "Offer for the custom image definition"
  default     = "Windows-11"
}

variable "image_sku" {
  type        = string
  description = "SKU for the custom image definition"
  default     = "win11-22h2-avd"
}

variable "hyper_v_generation" {
  type        = string
  description = "Hyper-V generation for the image definition"
  default     = "V2"
}

variable "image_replication_regions" {
  type        = list(string)
  description = "List of regions to replicate the image to"
  default     = []
}

############################################
# Marketplace Image Configuration
############################################
variable "marketplace_image_publisher" {
  type        = string
  description = "Publisher of the marketplace image"
  default     = "MicrosoftWindowsDesktop"
}

variable "marketplace_image_offer" {
  type        = string
  description = "Offer of the marketplace image"
  default     = "Windows-11"
}

variable "marketplace_image_sku" {
  type        = string
  description = "SKU of the marketplace image"
  default     = "win11-22h2-avd"
}

variable "marketplace_image_version" {
  type        = string
  description = "Version of the marketplace image"
  default     = "latest"
}

############################################
# Storage Configuration
############################################
variable "storage_account_name" {
  type        = string
  description = "Name of the storage account for FSLogix profiles"
  validation {
    condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24 && can(regex("^[a-z0-9]+$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 characters long and contain only lowercase letters and numbers."
  }
}

variable "storage_account_replication_type" {
  type        = string
  description = "Replication type for the storage account"
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account_replication_type)
    error_message = "Storage account replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "file_share_name" {
  type        = string
  description = "Name of the file share for FSLogix profiles"
  default     = "fslogix"
}

variable "file_share_quota_gb" {
  type        = number
  description = "Quota for the file share in GB"
  default     = 5120
}

variable "storage_allowed_ips" {
  type        = list(string)
  description = "List of IP addresses allowed to access the storage account"
  default     = []
}

############################################
# AVD Workspace Configuration
############################################
variable "workspace_name" {
  type        = string
  description = "Name of the AVD workspace"
}

variable "workspace_friendly_name" {
  type        = string
  description = "Friendly name of the AVD workspace"
  default     = ""
}

variable "workspace_description" {
  type        = string
  description = "Description of the AVD workspace"
  default     = ""
}

############################################
# AVD Host Pool Configuration
############################################
variable "host_pool_name" {
  type        = string
  description = "Name of the AVD host pool"
}

variable "host_pool_friendly_name" {
  type        = string
  description = "Friendly name of the AVD host pool"
  default     = ""
}

variable "host_pool_description" {
  type        = string
  description = "Description of the AVD host pool"
  default     = ""
}

variable "host_pool_type" {
  type        = string
  description = "Type of host pool (Pooled or Personal)"
  default     = "Pooled"
  validation {
    condition     = contains(["Pooled", "Personal"], var.host_pool_type)
    error_message = "Host pool type must be either 'Pooled' or 'Personal'."
  }
}

variable "host_pool_load_balancer_type" {
  type        = string
  description = "Load balancer type for the host pool"
  default     = "BreadthFirst"
  validation {
    condition     = contains(["BreadthFirst", "DepthFirst"], var.host_pool_load_balancer_type)
    error_message = "Load balancer type must be either 'BreadthFirst' or 'DepthFirst'."
  }
}

variable "host_pool_maximum_sessions_allowed" {
  type        = number
  description = "Maximum number of sessions allowed per session host"
  default     = 16
}

variable "host_pool_start_vm_on_connect" {
  type        = bool
  description = "Whether to start VMs on connect"
  default     = true
}

variable "host_pool_custom_rdp_properties" {
  type        = string
  description = "Custom RDP properties for the host pool"
  default     = "drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;use multimon:i:0"
}

variable "personal_desktop_assignment_type" {
  type        = string
  description = "Assignment type for personal desktops (Automatic or Direct)"
  default     = "Automatic"
  validation {
    condition     = contains(["Automatic", "Direct"], var.personal_desktop_assignment_type)
    error_message = "Personal desktop assignment type must be either 'Automatic' or 'Direct'."
  }
}

############################################
# Application Group Configuration
############################################
variable "desktop_application_group_name" {
  type        = string
  description = "Name of the desktop application group"
}

variable "desktop_application_group_friendly_name" {
  type        = string
  description = "Friendly name of the desktop application group"
  default     = ""
}

variable "desktop_application_group_description" {
  type        = string
  description = "Description of the desktop application group"
  default     = ""
}

############################################
# Scaling Plan Configuration
############################################
variable "enable_scaling_plan" {
  type        = bool
  description = "Whether to create a scaling plan"
  default     = false
}

variable "scaling_plan_name" {
  type        = string
  description = "Name of the scaling plan"
  default     = ""
}

variable "scaling_plan_friendly_name" {
  type        = string
  description = "Friendly name of the scaling plan"
  default     = ""
}

variable "scaling_plan_description" {
  type        = string
  description = "Description of the scaling plan"
  default     = ""
}

variable "scaling_plan_time_zone" {
  type        = string
  description = "Time zone for the scaling plan"
  default     = "Eastern Standard Time"
}

############################################
# Session Host Configuration
############################################
variable "session_host_count" {
  type        = number
  description = "Number of session hosts to create"
  default     = 2
}

variable "session_host_name_prefix" {
  type        = string
  description = "Prefix for session host names"
}

variable "session_host_vm_size" {
  type        = string
  description = "Size of the session host VMs"
  default     = "Standard_D2s_v3"
}

variable "session_host_disk_type" {
  type        = string
  description = "Storage account type for session host OS disks"
  default     = "Premium_LRS"
  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.session_host_disk_type)
    error_message = "Disk type must be one of: Standard_LRS, StandardSSD_LRS, Premium_LRS."
  }
}

variable "session_host_disk_size_gb" {
  type        = number
  description = "Size of the session host OS disk in GB"
  default     = 128
}

variable "vm_admin_username" {
  type        = string
  description = "Admin username for session host VMs"
  default     = "avdadmin"
}

variable "use_custom_image" {
  type        = bool
  description = "Whether to use custom image from compute gallery"
  default     = false
}

############################################
# Domain Configuration
############################################
variable "domain_join_type" {
  type        = string
  description = "Type of domain join (AzureAD or ActiveDirectory)"
  default     = "AzureAD"
  validation {
    condition     = contains(["AzureAD", "ActiveDirectory"], var.domain_join_type)
    error_message = "Domain join type must be either 'AzureAD' or 'ActiveDirectory'."
  }
}

variable "domain_name" {
  type        = string
  description = "Name of the Active Directory domain (required if domain_join_type is ActiveDirectory)"
  default     = ""
}

variable "domain_ou_path" {
  type        = string
  description = "OU path for domain-joined machines"
  default     = ""
}

variable "domain_join_username" {
  type        = string
  description = "Username for domain join operations"
  default     = ""
}

variable "domain_join_password" {
  type        = string
  description = "Password for domain join operations"
  default     = ""
  sensitive   = true
}