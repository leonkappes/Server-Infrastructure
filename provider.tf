provider "hcloud" {
  token = var.HCLOUD_KEY
}

provider "cloudflare" {
  api_token = var.CLOUDFLARE_KEY
}

terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
  required_version = ">= 0.14"
}
