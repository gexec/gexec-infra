resource "aws_s3_bucket" "download" {
  bucket = "dl.gexec.eu"
}

resource "aws_s3_bucket_website_configuration" "download" {
  bucket = aws_s3_bucket.download.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "download" {
  bucket = aws_s3_bucket.download.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "download" {
  bucket = aws_s3_bucket.download.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
        ]
        Resource = [
          aws_s3_bucket.download.arn,
          "${aws_s3_bucket.download.arn}/*",
        ]
      },
    ]
  })
}

resource "aws_s3_bucket_cors_configuration" "download" {
  bucket = aws_s3_bucket.download.bucket

  cors_rule {
    allowed_headers = [
      "*",
    ]
    allowed_methods = [
      "GET",
    ]
    allowed_origins = [
      "https://dl.gexec.eu",
    ]
    expose_headers = [
      "x-amz-server-side-encryption",
      "x-amz-request-id",
      "x-amz-id-2",
    ]
    max_age_seconds = 3000
  }
}

resource "aws_s3_object" "download" {
  bucket       = aws_s3_bucket.download.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
}

resource "cloudflare_dns_record" "download" {
  zone_id = cloudflare_zone.gexec.id
  name    = "dl"
  content = aws_s3_bucket_website_configuration.download.website_endpoint
  type    = "CNAME"
  ttl     = 1
  proxied = true
}
