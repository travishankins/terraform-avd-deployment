############################################
# Terraform & Providers
############################################
terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm" version = ">= 3.71" }
    random  = { source = "hashicorp/random"  version = ">= 3.6"  }
    azuread = { source = "hashicorp/azuread"  version = ">= 2.0"  }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azuread" {}

############################################
# Resource Group
############################################
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

############################################
# Networking
############################################
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "management" {
  name                 = "management"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.management_subnet_prefix]
}

resource "azurerm_subnet" "session" {
  name                 = "session-hosts"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.session_subnet_prefix]
}

############################################
# Log Analytics
############################################
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.resource_group_name}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

############################################
# FSLogix Storage
############################################
resource "azurerm_storage_account" "fslogix" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = var.storage_account_sku
  is_hns_enabled           = true
}

resource "azurerm_storage_share" "fslogix" {
  name                 = var.file_share_name
  storage_account_name = azurerm_storage_account.fslogix.name
  quota                = 5120
}

############################################
# AVD Control Plane
############################################
resource "azurerm_virtual_desktop_host_pool" "hp" {
  name                       = var.host_pool_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  friendly_name              = var.host_pool_friendly
  host_pool_type             = var.host_pool_type
  load_balancer_type         = var.host_pool_lb_type
  maximum_sessions_allowed   = var.host_pool_max_sessions
  start_vm_on_connect        = true
}

resource "azurerm_virtual_desktop_application_group" "ag" {
  name                = var.app_group_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  host_pool_id        = azurerm_virtual_desktop_host_pool.hp.id
  application_group_type = var.app_group_type
}

resource "azurerm_virtual_desktop_workspace" "ws" {
  name                = var.workspace_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "wsag" {
  workspace_id         = azurerm_virtual_desktop_workspace.ws.id
  application_group_id = azurerm_virtual_desktop_application_group.ag.id
}

resource "azurerm_virtual_desktop_scaling_plan" "sp" {
  name                = var.scaling_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  time_zone           = var.scaling_plan_time_zone
  schedule {
    name                               = "DefaultSchedule"
    days_of_week                       = var.scaling_plan_days
    ramp_up_start_time                 = "08:00"
    ramp_up_load_balancing_algorithm   = "BreadthFirst"
    ramp_up_minimum_hosts_percent      = 20
    peak_start_time                    = "09:00"
    ramp_down_start_time               = "18:00"
    ramp_down_load_balancing_algorithm = "DepthFirst"
    ramp_down_wait_time_minutes        = 30
    off_peak_start_time                = "20:00"
    off_peak_load_balancing_algorithm  = "DepthFirst"
  }
}

resource "azurerm_virtual_desktop_scaling_plan_host_pool_association" "sp_hp" {
  scaling_plan_id = azurerm_virtual_desktop_scaling_plan.sp.id
  host_pool_id    = azurerm_virtual_desktop_host_pool.hp.id
}

############################################
# Registration Token
############################################
resource "azurerm_virtual_desktop_host_pool_registration_info" "token" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.hp.id
  expiration_date = timeadd(timestamp(), var.registration_token_ttl)
}

############################################
# Session‑Host VMs
############################################
resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "${var.vm_name_prefix}-${count.index}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.session.id
  accelerated_networking_enabled = true
}

resource "random_password" "admin" {
  length  = 20
  special = true
}

resource "azurerm_windows_virtual_machine" "vm" {
  count                  = var.vm_count
  name                   = "${var.vm_name_prefix}-${count.index}"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  size                   = var.vm_size
  network_interface_ids  = [azurerm_network_interface.nic[count.index].id]
  admin_username         = "adminuser"
  admin_password         = random_password.admin.result
  identity {
    type = "SystemAssigned"
  }
  source_image_id        = data.azurerm_shared_image_version.sig.id
  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
}

resource "azurerm_virtual_machine_extension" "aad_join" {
  count               = var.vm_count
  name                = "aadJoin-${count.index}"
  publisher           = "Microsoft.Azure.ActiveDirectory"
  type                = "AADLoginForWindows"
  type_handler_version = "2.0"
  virtual_machine_id  = azurerm_windows_virtual_machine.vm[count.index].id
}

resource "azurerm_virtual_machine_extension" "avd_dsc" {
  count               = var.vm_count
  name                = "avdDSC-${count.index}"
  publisher           = "Microsoft.Powershell"
  type                = "DSC"
  type_handler_version = "2.73"
  virtual_machine_id  = azurerm_windows_virtual_machine.vm[count.index].id
  protected_settings  = jsonencode({ properties = { registrationInfoToken = azurerm_virtual_desktop_host_pool_registration_info.token.token } })
  settings            = jsonencode({ modulesUrl            = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02714.342.zip", configurationFunction = "Configuration.ps1\\AddSessionHost", properties = { HostPoolName = azurerm_virtual_desktop_host_pool.hp.name } })
  depends_on          = [azurerm_virtual_machine_extension.aad_join]
}

############################################
# FSLogix Role Assignment
############################################
resource "azurerm_role_assignment" "fslogix" {
  count                = var.vm_count
  scope                = azurerm_storage_share.fslogix.id
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = azurerm_windows_virtual_machine.vm[count.index].identity.principal_id
}

############################################
# Gallery Image Lookup
############################################
data "azurerm_shared_image_version" "sig" {
  name                = var.image_version
  image_name          = var.image_name
  gallery_name        = var.gallery_name
  resource_group_name = var.gallery_rg
}