# Server Infrastructure

> Infrastructure-as-Code for provisioning and configuring cloud servers using [Terraform](https://www.terraform.io/) & [Ansible](https://www.ansible.com/)

This repository contains the complete Infrastructure-as-Code (IaC) setup for my personal cloud environment. Terraform provisions the servers and manages DNS, while Ansible handles the server configuration.

The workloads running on this cluster are managed via my [Kubernetes-Flux](https://github.com/leonkappes/Kubernetes-Flux) repository.

---

## Architecture

```
Server-Infrastructure/
├── main.tf             # Hetzner Cloud server resources (masters & nodes)
├── cloudflare.tf       # Cloudflare DNS records
├── inventory.tf        # Auto-generates Ansible inventory from provisioned IPs
├── provider.tf         # Terraform provider config (hcloud + cloudflare)
├── variables.tf        # Input variables (API keys, SSH key, zone IDs)
├── output.tf           # Terraform outputs
├── templates/
│   └── hosts.tpl       # Ansible inventory template
└── ansible/
    └── roles           # configuration for master and worker k3s nodes
```

---

## How It Works

**Terraform** handles everything infrastructure-level: It provisions Hetzner Cloud VMs (control-plane masters and worker nodes), configures Cloudflare DNS records, and auto-generates the Ansible inventory file by rendering the `hosts.tpl` template with the real IP addresses of the freshly created servers.

**Ansible** takes the provisioned vms and uses the automaticaly generated inventory to setup k3s.

```
terraform apply
    ├── Provisions Hetzner Cloud VMs (masters + nodes)
    ├── Configures Cloudflare DNS records
    └── Writes ansible/inventory/hosts.cfg  ──► ansible-playbook ...
                                                    └── Configures servers
```

---

## Stack

| Tool | Purpose |
|---|---|
| [Terraform](https://www.terraform.io/) | Provisions cloud infrastructure declaratively |
| [Hetzner Cloud](https://www.hetzner.com/cloud) | Cloud provider for VMs (masters & worker nodes) |
| [Cloudflare](https://www.cloudflare.com/) | DNS management |
| [Ansible](https://www.ansible.com/) | Server configuration management |

---

## Getting Started

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 0.14
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html)
- A [Hetzner Cloud](https://console.hetzner.cloud/) account & API token
- A [Cloudflare](https://dash.cloudflare.com/) account with a configured zone

### 1. Configure Variables

Create a `terraform.tfvars` file (excluded from Git via `.gitignore`):

```hcl
HCLOUD_KEY            = "your-hetzner-api-token"
SSH_KEY               = "your-ssh-key"
CLOUDFLARE_KEY        = "your-cloudflare-api-token"
CLOUDFLARE_ZONE_ID    = "your-cloudflare-zone-id"
CLOUDFLARE_ACCOUNT_ID = "your-cloudflare-account-id"
```

### 2. Provision Infrastructure

```bash
# Initialize Terraform providers
terraform init

# Preview the planned changes
terraform plan

# Apply — provisions servers and DNS, generates Ansible inventory
terraform apply
```

### 3. Configure Servers with Ansible

Once `terraform apply` completes, the Ansible inventory at `ansible/inventory/hosts.cfg` is ready:

```bash
ansible-playbook ansible/site.yml -i ansible/inventory/hosts.cfg
```

---

## Security

All sensitive values (API keys, SSH keys, zone IDs) are defined as `sensitive` Terraform variables and must be supplied via `terraform.tfvars` or environment variables. They are never committed to the repository.

---

## Related

- **[Kubernetes-Flux](https://github.com/leonkappes/Kubernetes-Flux)** — GitOps configuration for the workloads running on this infrastructure
