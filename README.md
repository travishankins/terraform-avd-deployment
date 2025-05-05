# Azure Virtual Desktop Full-Stack Deployment

**This Terraform repo deploys a complete, best-practice AVD environment:**

- **Networking:** VNet with management & session-host subnets
- **Monitoring:** Log Analytics workspace
- **Storage:** Azure Files share for FSLogix profiles
- **Control Plane:** Host Pool, App Group, Workspace, Scaling Plan
- **Compute:** AAD‑joined Windows 11 session hosts with DSC

## Files
- `main.tf`             Core resource definitions
- `variables.tf`        Input variables & defaults
- `terraform.tfvars.sample` Example configuration values

## Quick Start
```bash
# 1. Copy and edit vars
cp terraform.tfvars.sample terraform.tfvars
# 2. Deploy
terraform init
terraform plan
terraform apply# terraform-avd-deployment
