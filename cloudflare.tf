resource "cloudflare_record" "a_at_record" {
  name            = "@"
  type            = "A"
  proxied         = true
  value           = hcloud_load_balancer.entry_loadbalancer.ipv4
  zone_id         = var.CLOUDFLARE_ZONE_ID
  allow_overwrite = true
}
