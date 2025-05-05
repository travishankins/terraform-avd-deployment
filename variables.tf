# Subscription & RG
type subscription_id    = string
variable "resource_group_name" { type = string }
variable "location"            { type = string }

# Networking
variable "vnet_name"            { type = string }
variable "vnet_address_space"   { type = list(string) }
variable "management_subnet_prefix" { type = string }
variable "session_subnet_prefix"    { type = string }

# Log Analytics
default law_retention = 30

# FSLogix Storage
variable "storage_account_name" { type = string }
variable "storage_account_sku"  { type = string }
variable "file_share_name"      { type = string }

# AVD Control Plane
variable "host_pool_name"         { type = string }
variable "host_pool_friendly"     { type = string }
variable "host_pool_type"         { type = string }
variable "host_pool_lb_type"      { type = string }
variable "host_pool_max_sessions" { type = number }
variable "app_group_name"         { type = string }
variable "app_group_type"         { type = string }
variable "workspace_name"         { type = string }
variable "scaling_plan_name"      { type = string }
variable "scaling_plan_time_zone" { type = string }
variable "scaling_plan_days"      { type = list(string) }

# Compute Gallery Image
variable "gallery_rg"       { type = string }
variable "gallery_name"     { type = string }
variable "image_name"       { type = string }
variable "image_version"    { type = string }
variable "registration_token_ttl" { type = string }

# Session Host VMs
variable "vm_count"        { type = number }
variable "vm_name_prefix"  { type = string }
variable "vm_size"         { type = string }