# Master IPs
output "master-ips" {
  value = hcloud_server.masters[*].ipv4_address
}

# Node IPs
output "node-ips" {
  value = hcloud_server.nodes[*].ipv4_address
}
