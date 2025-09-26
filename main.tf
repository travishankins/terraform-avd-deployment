############################################
# Data Sources
############################################
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

# Existing resource group for shared services (assuming already exists)
data "azurerm_resource_group" "shared_services" {
  count = var.create_resource_groups ? 0 : 1
  name  = var.shared_services_rg_name
}

# Existing virtual network # Storage Account for FSLogix
############################################
resource "azurerm_storage_account" "fslogix" {
  name                     = var.storage_account_name
  resource_group_name      = local.shared_services_rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.storage_account_replication_type
  is_hns_enabled           = true

  # Network rules for security
  network_rules {
    default_action             = var.enable_private_endpoints ? "Deny" : "Deny"
    ip_rules                   = var.enable_private_endpoints ? [] : var.storage_allowed_ips
    virtual_network_subnet_ids = var.enable_private_endpoints ? [] : (var.use_existing_network ? [local.subnet_id] : [])
    bypass                     = ["AzureServices"]
  }

  # Disable public network access when using private endpoints
  public_network_access_enabled = var.enable_private_endpoints ? false : true

  tags = var.tags
}

resource "azurerm_storage_share" "fslogix_profiles" {
  name                 = var.file_share_name
  storage_account_name = azurerm_storage_account.fslogix.name
  quota                = var.file_share_quota_gb
}

data "azurerm_virtual_network" "existing" {
  count               = var.use_existing_network ? 1 : 0
  name                = var.existing_vnet_name
  resource_group_name = var.existing_vnet_rg_name
}

data "azurerm_subnet" "existing_subnet" {
  count                = var.use_existing_network ? 1 : 0
  name                 = var.existing_subnet_name
  virtual_network_name = var.existing_vnet_name
  resource_group_name  = var.existing_vnet_rg_name
}

# Private endpoint subnet (if using private endpoints)
data "azurerm_subnet" "private_endpoint_subnet" {
  count                = var.enable_private_endpoints ? 1 : 0
  name                 = var.private_endpoint_subnet_name
  virtual_network_name = var.existing_vnet_name
  resource_group_name  = var.existing_vnet_rg_name
}

############################################
# Private DNS Zones (if enabled)
############################################
resource "azurerm_private_dns_zone" "storage_blob" {
  count               = var.enable_private_endpoints && var.create_private_dns_zones ? 1 : 0
  name                = var.private_dns_zones.storage_blob
  resource_group_name = local.shared_services_rg_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "storage_file" {
  count               = var.enable_private_endpoints && var.create_private_dns_zones ? 1 : 0
  name                = var.private_dns_zones.storage_file
  resource_group_name = local.shared_services_rg_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "key_vault" {
  count               = var.enable_private_endpoints && var.create_private_dns_zones ? 1 : 0
  name                = var.private_dns_zones.key_vault
  resource_group_name = local.shared_services_rg_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "log_analytics" {
  count               = var.enable_private_endpoints && var.create_private_dns_zones ? 1 : 0
  name                = var.private_dns_zones.log_analytics
  resource_group_name = local.shared_services_rg_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "compute_gallery" {
  count               = var.enable_private_endpoints && var.create_private_dns_zones ? 1 : 0
  name                = var.private_dns_zones.compute_gallery
  resource_group_name = local.shared_services_rg_name
  tags                = var.tags
}

# Link private DNS zones to virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob" {
  count                 = var.enable_private_endpoints && var.create_private_dns_zones ? 1 : 0
  name                  = "storage-blob-dns-link"
  resource_group_name   = local.shared_services_rg_name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob[0].name
  virtual_network_id    = data.azurerm_virtual_network.existing[0].id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_file" {
  count                 = var.enable_private_endpoints && var.create_private_dns_zones ? 1 : 0
  name                  = "storage-file-dns-link"
  resource_group_name   = local.shared_services_rg_name
  private_dns_zone_name = azurerm_private_dns_zone.storage_file[0].name
  virtual_network_id    = data.azurerm_virtual_network.existing[0].id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  count                 = var.enable_private_endpoints && var.create_private_dns_zones ? 1 : 0
  name                  = "key-vault-dns-link"
  resource_group_name   = local.shared_services_rg_name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault[0].name
  virtual_network_id    = data.azurerm_virtual_network.existing[0].id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "log_analytics" {
  count                 = var.enable_private_endpoints && var.create_private_dns_zones ? 1 : 0
  name                  = "log-analytics-dns-link"
  resource_group_name   = local.shared_services_rg_name
  private_dns_zone_name = azurerm_private_dns_zone.log_analytics[0].name
  virtual_network_id    = data.azurerm_virtual_network.existing[0].id
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "compute_gallery" {
  count                 = var.enable_private_endpoints && var.create_private_dns_zones ? 1 : 0
  name                  = "compute-gallery-dns-link"
  resource_group_name   = local.shared_services_rg_name
  private_dns_zone_name = azurerm_private_dns_zone.compute_gallery[0].name
  virtual_network_id    = data.azurerm_virtual_network.existing[0].id
  tags                  = var.tags
}

############################################
# Resource Groups
############################################
resource "azurerm_resource_group" "shared_services" {
  count    = var.create_resource_groups ? 1 : 0
  name     = var.shared_services_rg_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "avd_services" {
  count    = var.create_resource_groups ? 1 : 0
  name     = var.avd_services_rg_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "session_hosts" {
  count    = var.create_resource_groups ? 1 : 0
  name     = var.session_hosts_rg_name
  location = var.location
  tags     = var.tags
}

locals {
  shared_services_rg_name    = var.create_resource_groups ? azurerm_resource_group.shared_services[0].name : data.azurerm_resource_group.shared_services[0].name
  avd_services_rg_name       = var.create_resource_groups ? azurerm_resource_group.avd_services[0].name : var.avd_services_rg_name
  session_hosts_rg_name      = var.create_resource_groups ? azurerm_resource_group.session_hosts[0].name : var.session_hosts_rg_name
  subnet_id                  = var.use_existing_network ? data.azurerm_subnet.existing_subnet[0].id : null
  private_endpoint_subnet_id = var.enable_private_endpoints ? data.azurerm_subnet.private_endpoint_subnet[0].id : null
}

############################################
# Log Analytics Workspace
############################################
resource "azurerm_log_analytics_workspace" "avd" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = local.shared_services_rg_name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_analytics_retention_in_days
  tags                = var.tags
}

############################################
# Key Vault
############################################
resource "random_password" "vm_admin" {
  length  = 20
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "azurerm_key_vault" "avd" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = local.shared_services_rg_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.key_vault_sku

  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  # Disable public access when using private endpoints
  public_network_access_enabled = var.enable_private_endpoints ? false : true

  # Network ACLs
  network_acls {
    bypass                     = "AzureServices"
    default_action             = var.enable_private_endpoints ? "Deny" : "Allow"
    ip_rules                   = var.enable_private_endpoints ? [] : []
    virtual_network_subnet_ids = var.enable_private_endpoints ? [] : (var.use_existing_network ? [local.subnet_id] : [])
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "Purge"
    ]
  }

  tags = var.tags
}

resource "azurerm_key_vault_secret" "vm_admin_password" {
  name         = "vm-admin-password"
  value        = random_password.vm_admin.result
  key_vault_id = azurerm_key_vault.avd.id
  depends_on   = [azurerm_key_vault.avd]
}

############################################
# Azure Image Builder Resources
############################################
resource "random_uuid" "aib" {}

resource "random_string" "aib" {
  length  = 8
  special = false
  upper   = false
  numeric = false
  lower   = true
  keepers = {
    always_run = "${timestamp()}"
  }
}

resource "azurerm_user_assigned_identity" "aib" {
  name                = "uai-aib-${var.prefix}"
  resource_group_name = local.shared_services_rg_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_definition" "aib" {
  name        = "Azure Image Builder-${random_uuid.aib.result}"
  scope       = data.azurerm_subscription.current.id
  description = "Azure Image Builder AVD Custom Role"

  permissions {
    actions = [
      "Microsoft.Authorization/*/read",
      "Microsoft.Compute/images/write",
      "Microsoft.Compute/images/read",
      "Microsoft.Compute/images/delete",
      "Microsoft.Compute/galleries/read",
      "Microsoft.Compute/galleries/images/read",
      "Microsoft.Compute/galleries/images/versions/read",
      "Microsoft.Compute/galleries/images/versions/write",
      "Microsoft.Storage/storageAccounts/blobServices/containers/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/write",
      "Microsoft.ContainerInstance/containerGroups/read",
      "Microsoft.ContainerInstance/containerGroups/write",
      "Microsoft.ContainerInstance/containerGroups/start/action",
      "Microsoft.ManagedIdentity/userAssignedIdentities/*/read",
      "Microsoft.ManagedIdentity/userAssignedIdentities/*/assign/action",
      "Microsoft.Resources/deployments/*",
      "Microsoft.Resources/deploymentScripts/read",
      "Microsoft.Resources/deploymentScripts/write",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.VirtualMachineImages/imageTemplates/run/action",
      "Microsoft.VirtualMachineImages/imageTemplates/read",
      "Microsoft.Network/virtualNetworks/read",
      "Microsoft.Network/virtualNetworks/subnets/join/action"
    ]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id,
    "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${local.shared_services_rg_name}"
  ]
}

resource "azurerm_role_assignment" "aib" {
  scope              = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${local.shared_services_rg_name}"
  role_definition_id = azurerm_role_definition.aib.role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.aib.principal_id
}

resource "time_sleep" "aib" {
  depends_on      = [azurerm_role_assignment.aib]
  create_duration = "60s"
}

############################################
# Compute Gallery & Image Definition
############################################
resource "azurerm_shared_image_gallery" "avd" {
  name                = var.compute_gallery_name
  resource_group_name = local.shared_services_rg_name
  location            = var.location
  description         = "AVD Compute Gallery for custom images"
  tags                = var.tags
}

resource "azurerm_shared_image" "avd" {
  name                = var.image_definition_name
  gallery_name        = azurerm_shared_image_gallery.avd.name
  resource_group_name = local.shared_services_rg_name
  location            = var.location
  os_type             = "Windows"
  hyper_v_generation  = var.hyper_v_generation

  identifier {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
  }

  tags = var.tags
}

############################################
# Azure Image Builder Template
############################################
resource "azurerm_resource_group_template_deployment" "aib" {
  count               = var.enable_image_builder ? 1 : 0
  name                = "aib-${random_string.aib.result}"
  resource_group_name = local.shared_services_rg_name
  deployment_mode     = "Incremental"

  parameters_content = jsonencode({
    "imageTemplateName" = {
      value = "avd-image-template-${random_string.aib.result}"
    },
    "api-version" = {
      value = var.aib_api_version
    },
    "svclocation" = {
      value = var.location
    }
  })

  template_content = jsonencode({
    "$schema"        = "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#"
    "contentVersion" = "1.0.0.0"
    "parameters" = {
      "imageTemplateName" = {
        "type" = "string"
      }
      "api-version" = {
        "type" = "string"
      }
      "svclocation" = {
        "type" = "string"
      }
    }
    "variables" = {}
    "resources" = [
      {
        "name"       = "[parameters('imageTemplateName')]"
        "type"       = "Microsoft.VirtualMachineImages/imageTemplates"
        "apiVersion" = "[parameters('api-version')]"
        "location"   = "[parameters('svclocation')]"
        "dependsOn"  = []
        "tags" = {
          "imagebuilderTemplate" = "AzureImageBuilderAVD"
          "userIdentity"         = "enabled"
        }
        "identity" = {
          "type" = "UserAssigned"
          "userAssignedIdentities" = {
            "${azurerm_user_assigned_identity.aib.id}" = {}
          }
        }
        "properties" = {
          "buildTimeoutInMinutes" = var.aib_build_timeout
          "vmProfile" = {
            "vmSize" = var.aib_vm_size
            "vnetConfig" = var.use_existing_network ? {
              "subnetId" = local.subnet_id
            } : null
          }
          "source" = {
            "type"      = "PlatformImage"
            "publisher" = var.marketplace_image_publisher
            "offer"     = var.marketplace_image_offer
            "sku"       = var.marketplace_image_sku
            "version"   = var.marketplace_image_version
          }
          "customize" = [
            {
              "type"        = "PowerShell"
              "name"        = "InstallFSLogix"
              "runElevated" = true
              "scriptUri"   = "https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/scripts/Install-FSLogix.ps1"
            },
            {
              "type"                = "WindowsRestart"
              "restartCheckCommand" = "echo Azure-Image-Builder-Restarted-the-VM  > c:\\buildArtifacts\\azureImageBuilderRestart.txt"
              "restartTimeout"      = "5m"
            },
            {
              "type"           = "WindowsUpdate"
              "searchCriteria" = "IsInstalled=0"
              "filters" = [
                "exclude:$_.Title -like '*Preview*'",
                "include:$true"
              ]
              "updateLimit" = 40
            }
          ]
          "distribute" = [
            {
              "type"           = "SharedImage"
              "galleryImageId" = azurerm_shared_image.avd.id
              "runOutputName"  = "[parameters('imageTemplateName')]"
              "artifactTags" = {
                "source"    = "azureImageBuilder"
                "baseosimg" = "windows11"
              }
              "replicationRegions" = var.image_replication_regions
            }
          ]
        }
      }
    ]
  })

  depends_on = [
    time_sleep.aib,
    azurerm_shared_image.avd
  ]
}

############################################
# Private Endpoints (if enabled)
############################################

# Storage Account Private Endpoints
resource "azurerm_private_endpoint" "storage_blob" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "${var.storage_account_name}-blob-pe"
  location            = var.location
  resource_group_name = local.shared_services_rg_name
  subnet_id           = local.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.storage_account_name}-blob-psc"
    private_connection_resource_id = azurerm_storage_account.fslogix.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.create_private_dns_zones ? [1] : []
    content {
      name                 = "storage-blob-dns-zone-group"
      private_dns_zone_ids = [azurerm_private_dns_zone.storage_blob[0].id]
    }
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "storage_file" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "${var.storage_account_name}-file-pe"
  location            = var.location
  resource_group_name = local.shared_services_rg_name
  subnet_id           = local.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.storage_account_name}-file-psc"
    private_connection_resource_id = azurerm_storage_account.fslogix.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.create_private_dns_zones ? [1] : []
    content {
      name                 = "storage-file-dns-zone-group"
      private_dns_zone_ids = [azurerm_private_dns_zone.storage_file[0].id]
    }
  }

  tags = var.tags
}

# Key Vault Private Endpoint
resource "azurerm_private_endpoint" "key_vault" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "${var.key_vault_name}-pe"
  location            = var.location
  resource_group_name = local.shared_services_rg_name
  subnet_id           = local.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.key_vault_name}-psc"
    private_connection_resource_id = azurerm_key_vault.avd.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.create_private_dns_zones ? [1] : []
    content {
      name                 = "key-vault-dns-zone-group"
      private_dns_zone_ids = [azurerm_private_dns_zone.key_vault[0].id]
    }
  }

  tags = var.tags
}

# Compute Gallery Private Endpoint
resource "azurerm_private_endpoint" "compute_gallery" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "${var.compute_gallery_name}-pe"
  location            = var.location
  resource_group_name = local.shared_services_rg_name
  subnet_id           = local.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.compute_gallery_name}-psc"
    private_connection_resource_id = azurerm_shared_image_gallery.avd.id
    subresource_names              = ["gallery"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.create_private_dns_zones ? [1] : []
    content {
      name                 = "compute-gallery-dns-zone-group"
      private_dns_zone_ids = [azurerm_private_dns_zone.compute_gallery[0].id]
    }
  }

  tags = var.tags
}

############################################
# AVD Control Plane
############################################
resource "azurerm_virtual_desktop_workspace" "main" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = local.avd_services_rg_name
  friendly_name       = var.workspace_friendly_name
  description         = var.workspace_description
  tags                = var.tags
}

resource "azurerm_virtual_desktop_host_pool" "main" {
  name                             = var.host_pool_name
  location                         = var.location
  resource_group_name              = local.avd_services_rg_name
  type                             = var.host_pool_type
  friendly_name                    = var.host_pool_friendly_name
  description                      = var.host_pool_description
  load_balancer_type               = var.host_pool_load_balancer_type
  maximum_sessions_allowed         = var.host_pool_maximum_sessions_allowed
  start_vm_on_connect              = var.host_pool_start_vm_on_connect
  custom_rdp_properties            = var.host_pool_custom_rdp_properties
  personal_desktop_assignment_type = var.host_pool_type == "Personal" ? var.personal_desktop_assignment_type : null
  tags                             = var.tags
}

resource "azurerm_virtual_desktop_application_group" "desktop" {
  name                = var.desktop_application_group_name
  location            = var.location
  resource_group_name = local.avd_services_rg_name
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.main.id
  friendly_name       = var.desktop_application_group_friendly_name
  description         = var.desktop_application_group_description
  tags                = var.tags
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "desktop" {
  workspace_id         = azurerm_virtual_desktop_workspace.main.id
  application_group_id = azurerm_virtual_desktop_application_group.desktop.id
}

# Scaling Plan - Simplified for compatibility
resource "azurerm_virtual_desktop_scaling_plan" "main" {
  count               = var.enable_scaling_plan ? 1 : 0
  name                = var.scaling_plan_name
  location            = var.location
  resource_group_name = local.avd_services_rg_name
  friendly_name       = var.scaling_plan_friendly_name
  description         = var.scaling_plan_description
  time_zone           = var.scaling_plan_time_zone

  # Use simplified schedule configuration for better compatibility
  schedule {
    name         = "WeekdaySchedule"
    days_of_week = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]

    ramp_up_start_time                 = "08:00"
    ramp_up_load_balancing_algorithm   = "BreadthFirst"
    ramp_up_minimum_hosts_percent      = 20
    ramp_up_capacity_threshold_percent = 80

    peak_start_time               = "09:00"
    peak_load_balancing_algorithm = "BreadthFirst"

    ramp_down_start_time                 = "18:00"
    ramp_down_load_balancing_algorithm   = "DepthFirst"
    ramp_down_minimum_hosts_percent      = 10
    ramp_down_capacity_threshold_percent = 90
    ramp_down_force_logoff_users         = false
    ramp_down_wait_time_minutes          = 30
    ramp_down_notification_message       = "Please save your work. You will be logged off in 30 minutes."
    ramp_down_stop_hosts_when            = "ZeroActiveSessions"

    off_peak_start_time               = "20:00"
    off_peak_load_balancing_algorithm = "DepthFirst"
  }

  tags = var.tags
}

resource "azurerm_virtual_desktop_scaling_plan_host_pool_association" "main" {
  count           = var.enable_scaling_plan ? 1 : 0
  scaling_plan_id = azurerm_virtual_desktop_scaling_plan.main[0].id
  host_pool_id    = azurerm_virtual_desktop_host_pool.main.id
  enabled         = true
}

############################################
# Registration Token
############################################
resource "time_rotating" "registration_token" {
  rotation_days = 29
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "main" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.main.id
  expiration_date = time_rotating.registration_token.rotation_rfc3339
}

############################################
# Session Host VMs
############################################
resource "azurerm_network_interface" "session_host" {
  count               = var.session_host_count
  name                = "${var.session_host_name_prefix}-${count.index + 1}-nic"
  location            = var.location
  resource_group_name = local.session_hosts_rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "session_host" {
  count               = var.session_host_count
  name                = "${var.session_host_name_prefix}-${count.index + 1}"
  resource_group_name = local.session_hosts_rg_name
  location            = var.location
  size                = var.session_host_vm_size
  admin_username      = var.vm_admin_username
  admin_password      = random_password.vm_admin.result

  network_interface_ids = [
    azurerm_network_interface.session_host[count.index].id,
  ]

  identity {
    type = "SystemAssigned"
  }

  # Use custom image if available, otherwise marketplace image
  source_image_id = var.use_custom_image && var.enable_image_builder ? azurerm_shared_image.avd.id : null

  dynamic "source_image_reference" {
    for_each = var.use_custom_image && var.enable_image_builder ? [] : [1]
    content {
      publisher = var.marketplace_image_publisher
      offer     = var.marketplace_image_offer
      sku       = var.marketplace_image_sku
      version   = var.marketplace_image_version
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.session_host_disk_type
    disk_size_gb         = var.session_host_disk_size_gb
  }

  tags = var.tags
}

############################################
# VM Extensions
############################################

# Azure AD Join Extension
resource "azurerm_virtual_machine_extension" "aad_join" {
  count                      = var.domain_join_type == "AzureAD" ? var.session_host_count : 0
  name                       = "AADLoginForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true
}

# Domain Join Extension (for ADDS)
resource "azurerm_virtual_machine_extension" "domain_join" {
  count                      = var.domain_join_type == "ActiveDirectory" ? var.session_host_count : 0
  name                       = "DomainJoin"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    Name    = var.domain_name
    OUPath  = var.domain_ou_path
    User    = "${var.domain_name}\\${var.domain_join_username}"
    Restart = "true"
    Options = "3"
  })

  protected_settings = jsonencode({
    Password = var.domain_join_password
  })

  depends_on = [azurerm_windows_virtual_machine.session_host]
}

# AVD Agent Extension
resource "azurerm_virtual_machine_extension" "avd_agent" {
  count                      = var.session_host_count
  name                       = "Microsoft.PowerShell.DSC"
  virtual_machine_id         = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  protected_settings = jsonencode({
    properties = {
      registrationInfoToken = azurerm_virtual_desktop_host_pool_registration_info.main.token
    }
  })

  settings = jsonencode({
    modulesUrl            = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02714.342.zip"
    configurationFunction = "Configuration.ps1\\AddSessionHost"
    properties = {
      HostPoolName                           = azurerm_virtual_desktop_host_pool.main.name
      RegistrationInfoToken                  = azurerm_virtual_desktop_host_pool_registration_info.main.token
      aadJoin                                = var.domain_join_type == "AzureAD" ? true : false
      UseAgentDownloadEndpoint               = true
      aadJoinPreview                         = false
      mdmId                                  = ""
      sessionHostConfigurationLastUpdateTime = ""
    }
  })

  depends_on = [
    azurerm_virtual_machine_extension.aad_join,
    azurerm_virtual_machine_extension.domain_join
  ]
}

############################################
# RBAC Assignments for FSLogix
############################################
resource "azurerm_role_assignment" "storage_file_data_smb_share_contributor" {
  count                = var.session_host_count
  scope                = azurerm_storage_share.fslogix_profiles.id
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = azurerm_windows_virtual_machine.session_host[count.index].identity[0].principal_id
}

############################################
# Diagnostic Settings
############################################
resource "azurerm_monitor_diagnostic_setting" "host_pool" {
  name                       = "avd-hostpool-diag"
  target_resource_id         = azurerm_virtual_desktop_host_pool.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.avd.id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_log {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "workspace" {
  name                       = "avd-workspace-diag"
  target_resource_id         = azurerm_virtual_desktop_workspace.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.avd.id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_log {
    category = "AllMetrics"
  }
}