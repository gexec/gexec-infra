resource "cloudflare_dns_record" "github" {
  zone_id = var.cloudflare_zone
  name    = "_gh-gexec-o"
  content = "f4e2a5a366"
  type    = "TXT"
  ttl     = 1
  proxied = false
}
