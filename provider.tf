provider "hcloud" {
  token = var.HCLOUD_KEY
}

terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
  required_version = ">= 0.14"
}
