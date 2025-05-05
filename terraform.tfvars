subscription_id       = "00000000-0000-0000-0000-000000000000"
resource_group_name   = "rg-avd-full"
location              = "eastus"

# Network
vnet_name               = "avd-vnet"
vnet_address_space      = ["10.0.0.0/16"]
management_subnet_prefix = "10.0.0.0/24"
session_subnet_prefix    = "10.0.1.0/24"

# FSLogix
storage_account_name  = "stfslogix001"
storage_account_sku   = "Standard_LRS"
file_share_name       = "fslogix"

# AVD
host_pool_name         = "hp-full-avd"
host_pool_friendly     = "Full AVD Pool"
host_pool_type         = "Pooled"
host_pool_lb_type      = "BreadthFirst"
host_pool_max_sessions = 16
app_group_name         = "ag-full-avd"
app_group_type         = "Desktop"
workspace_name         = "ws-full-avd"
scaling_plan_name      = "sp-full-avd"
scaling_plan_time_zone = "Pacific Standard Time"
scaling_plan_days      = ["Monday","Tuesday","Wednesday","Thursday","Friday"]

# Compute Gallery Image
gallery_rg    = "rg-gallery"
gallery_name  = "corp-images"
image_name    = "win11-avd"
image_version = "latest"

# VM
token_ttl      = "72h"
vm_count       = 2
vm_name_prefix = "avdsh"
vm_size        = "Standard_D2s_v4"