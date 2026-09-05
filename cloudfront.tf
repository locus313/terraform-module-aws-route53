# CloudFront Origin Access Control
# Authenticates CloudFront to the private S3 bucket using SigV4 signing.
# The S3 origin is never actually reached (the CloudFront Function short-circuits all requests),
# but OAC ensures the origin remains inaccessible if the function were ever disabled.
resource "aws_cloudfront_origin_access_control" "records_wr" {
  for_each = local.records_wr

  name                              = "oac-${each.key}"
  description                       = "OAC for ${each.key} web redirect bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Function to perform HTTPS redirect at the viewer-request stage.
# The function intercepts every viewer request and returns a 301 immediately,
# so the S3 origin is never reached.
# Function name constraints: max 64 chars, only [a-zA-Z0-9-_] allowed.
resource "aws_cloudfront_function" "records_wr" {
  for_each = local.records_wr

  name    = "redirect-${replace(each.key, ".", "-")}"
  runtime = "cloudfront-js-2.0"
  comment = "Redirect ${each.key} to ${each.value}"
  publish = true

  # each.value is already a complete URL (validated in variables.tf), so it is rendered
  # as-is - it must not be treated as a bare hostname or have the visitor path appended.
  code = templatefile("${path.module}/templates/redirect-function.js.tftpl", {
    target_url = each.value
  })
}

# tfsec:ignore:AWS045 - CloudFront access logging not required for simple redirect use case
# tfsec:ignore:AWS071 - WAF not required for simple redirect distributions
resource "aws_cloudfront_distribution" "records_wr" {
  for_each = local.records_wr

  enabled      = true
  http_version = "http2"
  aliases      = [each.key]
  price_class  = "PriceClass_100" # US, Canada, and Europe
  tags         = var.tags

  origin {
    origin_id                = "origin-${each.key}"
    domain_name              = aws_s3_bucket.records_wr[each.key].bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.records_wr[each.key].id
  }

  default_cache_behavior {
    target_origin_id = "origin-${each.key}"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true
    # tfsec:ignore:AWS020 - HTTP viewer requests are redirected to HTTPS target by the CloudFront Function
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

    # Intercept all viewer requests and return a 301 before the origin is ever contacted
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.records_wr[each.key].arn
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
