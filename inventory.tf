resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/templates/hosts.tpl",
    tomap({
      masters = hcloud_server.masters[*].ipv6_address
      nodes   = hcloud_server.nodes[*].ipv4_address
    })
  )
  filename = "./ansible/inventory/hosts.cfg"
}
