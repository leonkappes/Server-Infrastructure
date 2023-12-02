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

resource "hcloud_load_balancer" "entry_loadbalancer" {
  name               = "entry_loadbalancer"
  load_balancer_type = "lb11"
  network_zone       = "eu-central"

  algorithm {
    type = "round_robin"
  }
}

resource "hcloud_load_balancer_target" "entry_loadbalancer_targets" {
  for_each         = { for k, instance in hcloud_server.nodes[*] : k => instance }
  type             = "server"
  load_balancer_id = hcloud_load_balancer.entry_loadbalancer.id
  server_id        = each.value.id
}

resource "hcloud_load_balancer_network" "entry_loadbalancer_network" {
  load_balancer_id = hcloud_load_balancer.entry_loadbalancer.id
  network_id       = hcloud_network.k3s_internal.id
  ip               = "10.0.0.254"
}

resource "hcloud_managed_certificate" "wildcard_cert" {
  name         = "wildcard_cert"
  domain_names = ["*.kappes.space", "kappes.space"]
}

resource "hcloud_load_balancer_service" "entry_loadbalancer_service" {
  load_balancer_id = hcloud_load_balancer.entry_loadbalancer.id
  protocol         = "https"
  listen_port      = "443"
  destination_port = "80"
  proxyprotocol    = true

  http {
    sticky_sessions = true
    certificates    = [hcloud_managed_certificate.wildcard_cert.id]
    redirect_http   = true
  }
  health_check {
    protocol = "http"
    port     = "443"
    interval = "10"
    timeout  = "10"
    http {
      domain       = "kappes.space"
      path         = "/"
      status_codes = ["2??", "3??"]
      tls          = true
    }
  }
}

resource "hcloud_placement_group" "placement_group_master" {
  name = "placement_group_master"
  type = "spread"
}

resource "hcloud_placement_group" "placement_group_nodes" {
  name = "placement_group_nodes"
  type = "spread"
}

resource "hcloud_server" "masters" {
  count              = 3
  name               = "k3s-master-${count.index + 1}"
  server_type        = "cx11"
  image              = "debian-12"
  ssh_keys           = ["SSH_KEY"]
  location           = "fsn1"
  placement_group_id = hcloud_placement_group.placement_group_master.id
  labels = {
    type = "master"
  }
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
  network {
    network_id = hcloud_network.k3s_internal.id
    ip         = "10.0.0.1${count.index + 1}"
  }

  depends_on = [hcloud_network_subnet.k3s_internal_subnet]
}

resource "hcloud_server" "nodes" {
  count              = 2
  name               = "k3s-node-${count.index + 1}"
  server_type        = "cx11"
  image              = "debian-12"
  ssh_keys           = ["SSH_KEY"]
  location           = "fsn1"
  placement_group_id = hcloud_placement_group.placement_group_nodes.id
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
