resource "aws_s3_bucket" "mon_bucket" {
  bucket = "sameddemet"
}

resource "aws_s3_bucket_website_configuration" "s3web" {
  bucket = aws_s3_bucket.mon_bucket.bucket

  index_document {
    suffix = "index.html"
  }

}

output "url" {
  value = aws_s3_bucket_website_configuration.s3web.website_endpoint
}

resource "aws_s3_object" "monindex" {
  depends_on = [
    aws_s3_bucket_acl.example
  ]
  bucket = aws_s3_bucket.mon_bucket.bucket
  key    = "index.html"
  source = "index.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.mon_bucket.bucket
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.mon_bucket.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.mon_bucket.bucket
  acl    = "public-read"
}

locals {
  s3_origin_id = "myS3Origin"
}
resource "aws_cloudfront_distribution" "monsite-cdn" {
  origin {
    domain_name = aws_s3_bucket.mon_bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }
  
#  aliases = [aws_route53_record.www.domain_name]

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "CloudFront distribution for monsite"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl               = 0
    default_ttl           = 3600
    max_ttl               = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  
#  viewer_certificate {
#    acm_certificate_arn      = "arn:aws:acm:eu-west-3:339713030032:certificate/ab119859-d359-4875-a799-31b986e7f58d"
#    ssl_support_method       = "sni-only"
#    minimum_protocol_version = "TLSv1.2_2021"
  }
}

data "aws_route53_zone" "mazone" {
  name = "devops.oclock.school"
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.mazone.zone_id
  name    = var.bucket_prefix
  type    = "A"
   
  alias {
    name                   = aws_cloudfront_distribution.monsite-cdn.domain_name
    zone_id               = aws_cloudfront_distribution.monsite-cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

