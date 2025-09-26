############################################
# Resource Group Outputs
############################################
output "shared_services_resource_group_name" {
  description = "Name of the shared services resource group"
  value       = local.shared_services_rg_name
}

output "avd_services_resource_group_name" {
  description = "Name of the AVD services resource group"
  value       = local.avd_services_rg_name
}

output "session_hosts_resource_group_name" {
  description = "Name of the session hosts resource group"
  value       = local.session_hosts_rg_name
}

############################################
# Log Analytics Outputs
############################################
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.avd.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.avd.name
}

############################################
# Key Vault Outputs
############################################
output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.avd.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.avd.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.avd.vault_uri
}

############################################
# Azure Image Builder Outputs
############################################
output "compute_gallery_id" {
  description = "ID of the Azure Compute Gallery"
  value       = azurerm_shared_image_gallery.avd.id
}

output "compute_gallery_name" {
  description = "Name of the Azure Compute Gallery"
  value       = azurerm_shared_image_gallery.avd.name
}

output "image_definition_id" {
  description = "ID of the image definition"
  value       = azurerm_shared_image.avd.id
}

output "image_definition_name" {
  description = "Name of the image definition"
  value       = azurerm_shared_image.avd.name
}

output "aib_user_assigned_identity_id" {
  description = "ID of the Azure Image Builder user assigned identity"
  value       = azurerm_user_assigned_identity.aib.id
}

output "aib_user_assigned_identity_client_id" {
  description = "Client ID of the Azure Image Builder user assigned identity"
  value       = azurerm_user_assigned_identity.aib.client_id
}

############################################
# Storage Outputs
############################################
output "storage_account_id" {
  description = "ID of the FSLogix storage account"
  value       = azurerm_storage_account.fslogix.id
}

output "storage_account_name" {
  description = "Name of the FSLogix storage account"
  value       = azurerm_storage_account.fslogix.name
}

output "file_share_name" {
  description = "Name of the FSLogix file share"
  value       = azurerm_storage_share.fslogix_profiles.name
}

output "file_share_url" {
  description = "URL of the FSLogix file share"
  value       = azurerm_storage_share.fslogix_profiles.url
}

############################################
# AVD Control Plane Outputs
############################################
output "workspace_id" {
  description = "ID of the AVD workspace"
  value       = azurerm_virtual_desktop_workspace.main.id
}

output "workspace_name" {
  description = "Name of the AVD workspace"
  value       = azurerm_virtual_desktop_workspace.main.name
}

output "host_pool_id" {
  description = "ID of the AVD host pool"
  value       = azurerm_virtual_desktop_host_pool.main.id
}

output "host_pool_name" {
  description = "Name of the AVD host pool"
  value       = azurerm_virtual_desktop_host_pool.main.name
}

output "desktop_application_group_id" {
  description = "ID of the desktop application group"
  value       = azurerm_virtual_desktop_application_group.desktop.id
}

output "desktop_application_group_name" {
  description = "Name of the desktop application group"
  value       = azurerm_virtual_desktop_application_group.desktop.name
}

output "scaling_plan_id" {
  description = "ID of the scaling plan"
  value       = var.enable_scaling_plan ? azurerm_virtual_desktop_scaling_plan.main[0].id : null
}

output "scaling_plan_name" {
  description = "Name of the scaling plan"
  value       = var.enable_scaling_plan ? azurerm_virtual_desktop_scaling_plan.main[0].name : null
}

############################################
# Session Host Outputs
############################################
output "session_host_names" {
  description = "Names of the session host VMs"
  value       = azurerm_windows_virtual_machine.session_host[*].name
}

output "session_host_ids" {
  description = "IDs of the session host VMs"
  value       = azurerm_windows_virtual_machine.session_host[*].id
}

output "session_host_private_ips" {
  description = "Private IP addresses of the session hosts"
  value       = azurerm_network_interface.session_host[*].private_ip_address
}

############################################
# Registration Token (sensitive)
############################################
output "host_pool_registration_token" {
  description = "Registration token for the host pool"
  value       = azurerm_virtual_desktop_host_pool_registration_info.main.token
  sensitive   = true
}

output "host_pool_registration_expiration" {
  description = "Expiration date of the registration token"
  value       = azurerm_virtual_desktop_host_pool_registration_info.main.expiration_date
}

############################################
# VM Admin Password (sensitive)
############################################
output "vm_admin_password" {
  description = "Admin password for session host VMs"
  value       = random_password.vm_admin.result
  sensitive   = true
}