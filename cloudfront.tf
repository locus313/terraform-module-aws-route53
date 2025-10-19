# tfsec:ignore:AWS045 - CloudFront access logging not required for simple redirect use case
# tfsec:ignore:AWS071 - WAF not required for simple redirect distributions
resource "aws_cloudfront_distribution" "records_wr" {
  for_each = var.records_wr

  enabled      = true
  http_version = "http2"
  aliases      = [each.key]
  price_class  = "PriceClass_100" # US, Canada, and Europe

  origin {
    origin_id   = "origin-${each.key}"
    domain_name = aws_s3_bucket_website_configuration.records_wr[each.key].website_endpoint

    # Use custom_origin_config instead of s3_origin_config because:
    # 1. S3 website endpoints don't support HTTPS origins
    # 2. S3 website hosting is required for proper redirect behavior
    # 3. This allows CloudFront to fetch from the S3 website endpoint over HTTP
    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    # Authenticate CloudFront requests to S3 using custom User-Agent header
    # This acts as a shared secret between CloudFront and S3 bucket policy
    custom_header {
      name  = "User-Agent"
      value = base64sha512("REFER-SECRET-19265125-${each.key}-43568442")
    }
  }

  default_cache_behavior {
    target_origin_id = "origin-${each.key}"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true
    # tfsec:ignore:AWS020 - Allow HTTP for redirect use case (CloudFront handles HTTPS)
    # tfsec:ignore:AWS072 - Same as AWS020
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 300  # 5 minutes
    max_ttl                = 1200 # 20 minutes

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.records_wr[each.key].certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021" # tfsec:ignore:AWS021 - TLSv1.2 is acceptable for this use case
  }

  depends_on = [
    aws_acm_certificate.records_wr,
    aws_acm_certificate_validation.records_wr
  ]
}
