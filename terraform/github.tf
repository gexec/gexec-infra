resource "cloudflare_dns_record" "github" {
  zone_id = cloudflare_zone.gexec.id
  name    = "_gh-gexec-o"
  content = "f4e2a5a366"
  type    = "TXT"
  ttl     = 1
  proxied = false
}
