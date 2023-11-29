resource "hcloud_ssh_key" "default" {
  name       = "SSH_KEY"
  public_key = var.SSH_KEY
}

resource "hcloud_network" "k3s_internal" {
  ip_range = "10.0.0.0/24"
  name     = "k3s-internal"
}

resource "hcloud_network_subnet" "k3s_internal_subnet" {
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.0.0/24"
  network_id   = hcloud_network.k3s_internal.id
}


resource "hcloud_server" "masters" {
  count       = 3
  name        = "k3s-master-${count.index + 1}"
  server_type = "cx11"
  image       = "debian-12"
  ssh_keys    = ["SSH_KEY"]
  location    = "fsn1"
  labels = {
    type = "master"
  }
  public_net {
    ipv4_enabled = false
    ipv6_enabled = true
  }
  network {
    network_id = hcloud_network.k3s_internal.id
    ip         = "10.0.0.1${count.index + 1}"
  }

  depends_on = [hcloud_network_subnet.k3s_internal_subnet]
}

resource "hcloud_server" "nodes" {
  count       = 2
  name        = "k3s-node-${count.index + 1}"
  server_type = "cx21"
  image       = "debian-12"
  ssh_keys    = ["SSH_KEY"]
  location    = "fsn1"
  labels = {
    type = "node"
  }
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
  network {
    network_id = hcloud_network.k3s_internal.id
    ip         = "10.0.0.2${count.index + 1}"
  }

  depends_on = [hcloud_network_subnet.k3s_internal_subnet]
}
