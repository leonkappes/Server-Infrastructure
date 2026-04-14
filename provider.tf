provider "hcloud" {
  token = var.HCLOUD_KEY
}

provider "cloudflare" {
  api_token = var.CLOUDFLARE_KEY
}

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.49"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
  required_version = ">= 1.0"
}
