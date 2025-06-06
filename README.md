# Terraform Azure Virtual Desktop Deployment 🚀🖥️


> **Deploy a complete Azure Virtual Desktop (AVD) environment in minutes—fully automated with Terraform.**

---

## 🗺️ What you get

| Icon | Component                                                 |
| ---- | --------------------------------------------------------- |
| 🏢   | **Host Pool** (pooled or personal)                        |
| 🖥️  | **Session Hosts** with custom image & sizing              |
| 🛡️  | **Network + NSGs** ready for production                   |
| 🔑   | **Key Vault** for secrets, joined to **AAD DS** or **AD** |
| 📊   | **Monitoring** via Log Analytics & diagnostic settings    |
| ⚙️   | **Scaling script** (optional) using Azure Automation      |

## ⚡ Quick start

```bash
az login
az account set --subscription "<target-subscription>"

# Clone
 git clone https://github.com/travishankins/terraform-avd-deployment.git
 cd terraform-avd-deployment

# Init & deploy
 terraform init
 terraform apply -var-file="avd.tfvars"
```

> Customize `avd.tfvars` for host pool name, VM size, image, region, and AD join type.

## 🌳 Repo layout

```
.
├── main.tf            # Root composition
├── variables.tf       # Inputs
├── outputs.tf         # Exports
└── modules/
    ├── hostpool/
    ├── sessionhosts/
    ├── networking/
    └── monitoring/
```

## 🔧 Common tweaks

* **VM count / size** → `session_host_count`, `session_host_size`
* **Domain join** → toggle `join_type` (AAD, AADDS, AD)
* **Scaling** → enable `enable_autoscale` and adjust schedule in `modules/scaling`


## 📚 Resources

* [AVD docs](https://aka.ms/avd/docs)
* [Terraform AVD module](https://registry.terraform.io/modules/Azure/avd/azurerm)


