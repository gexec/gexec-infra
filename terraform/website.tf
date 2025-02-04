data "aws_cloudfront_cache_policy" "managed_caching_optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_s3_bucket" "website" {
  bucket = "gexec-docs"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Principal = {
          "Service" : "cloudfront.amazonaws.com"
        }
        Action = [
          "s3:GetObject",
        ]
        Resource = [
          "${aws_s3_bucket.website.arn}/*",
        ]
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website.arn
          }
        }
      },
    ]
  })
}

resource "aws_cloudfront_response_headers_policy" "website" {
  name = "website-headers"

  security_headers_config {
    content_security_policy {
      override                = true
      content_security_policy = "default-src 'self'"
    }

    frame_options {
      override     = true
      frame_option = "DENY"
    }

    xss_protection {
      override   = true
      protection = true
      mode_block = true
    }

    content_type_options {
      override = true
    }

    referrer_policy {
      override        = true
      referrer_policy = "strict-origin-when-cross-origin"
    }
  }
}

resource "aws_cloudfront_function" "redirect" {
  name    = "redirect-www-to-root"
  runtime = "cloudfront-js-1.0"
  comment = "Redirect www.gexec.eu to gexec.eu"

  code = <<-EOT
    function handler(event) {
      var request = event.request;

      if (request.headers.host.value === "www.gexec.eu") {
        return {
          statusCode: 301,
          statusDescription: "Moved Permanently",
          headers: {
            "location": { "value": "https://gexec.eu/usage/overview/" }
          }
        };
      }

      if (request.uri === "/" || request.uri === "/index.html") {
        return {
          statusCode: 301,
          statusDescription: "Moved Permanently",
          headers: {
            "location": { "value": "https://gexec.eu/usage/overview/" }
          }
        };
      }

      if (request.uri.endsWith("/")) {
        request.uri += "index.html";
      }

      return request;
    }
  EOT
}

resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = ["gexec.eu", "www.gexec.eu"]

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/404.html"
  }

  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = "S3Origin"
    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.website.id
    cache_policy_id            = data.aws_cloudfront_cache_policy.managed_caching_optimized.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.redirect.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.website.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}

resource "aws_acm_certificate" "website" {
  provider                  = aws.us-east-1
  domain_name               = "gexec.eu"
  subject_alternative_names = ["www.gexec.eu"]
  validation_method         = "DNS"
}

resource "aws_acm_certificate_validation" "website" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.website.arn
  validation_record_fqdns = [for record in cloudflare_dns_record.website : record.name]
}

resource "cloudflare_dns_record" "website" {
  for_each = {
    for row in aws_acm_certificate.website.domain_validation_options : row.domain_name => {
      name    = row.resource_record_name
      content = row.resource_record_value
      type    = row.resource_record_type
    }
  }

  zone_id = var.cloudflare_zone
  name    = each.value.name
  content = each.value.content
  type    = each.value.type
  ttl     = 60
  proxied = false
}

resource "cloudflare_dns_record" "root" {
  zone_id = var.cloudflare_zone
  name    = "@"
  content = aws_cloudfront_distribution.website.domain_name
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "www" {
  zone_id = var.cloudflare_zone
  name    = "www"
  content = "gexec.eu"
  type    = "CNAME"
  ttl     = 1
  proxied = false
}
