resource "cloudflare_dns_record" "root" {
  zone_id = cloudflare_zone.gexec.id
  name    = "@"
  content = "gexec-docs.netlify.com"
  type    = "CNAME"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "www" {
  zone_id = cloudflare_zone.gexec.id
  name    = "www"
  content = "gexec-docs.netlify.com"
  type    = "CNAME"
  proxied = false
  ttl     = 1
}
