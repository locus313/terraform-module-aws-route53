resource "aws_cloudfront_distribution" "records_wr" {
  depends_on = [aws_acm_certificate.records_wr]
  count      = length(keys(var.records_wr))
  http_version = "http2"

  origin {
    origin_id   = "origin-${element(keys(var.records_wr), count.index )}"
    domain_name = aws_s3_bucket.records_wr[count.index].website_endpoint

    # https://docs.aws.amazon.com/AmazonCloudFront/latest/
    # DeveloperGuide/distribution-web-values-specify.html
    custom_origin_config {
      # "HTTP Only: CloudFront uses only HTTP to access the origin."
      # "Important: If your origin is an Amazon S3 bucket configured
      # as a website endpoint, you must choose this option. Amazon S3
      # doesn't support HTTPS connections for website endpoints."
      origin_protocol_policy = "http-only"

      http_port = "80"
      https_port = "443"

      # TODO: given the origin_protocol_policy set to `http-only`,
      # not sure what this does...
      # "If the origin is an Amazon S3 bucket, CloudFront always uses TLSv1.2."
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    # s3_origin_config is not compatible with S3 website hosting, if this
    # is used, /news/index.html will not resolve as /news/.
    # https://www.reddit.com/r/aws/comments/6o8f89/can_you_force_cloudfront_only_access_while_using/
    # s3_origin_config {
    #   origin_access_identity = "${aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path}"
    # }
    # Instead, we use a secret to authenticate CF requests to S3 policy.
    # Not the best, but...
    custom_header {
      name  = "User-Agent"
      value = base64sha512("REFER-SECRET-19265125-${element(keys(var.records_wr), count.index )}-43568442")
    }

  }

  enabled = true

  aliases = [element(keys(var.records_wr), count.index )]

  price_class = "PriceClass_100"

  default_cache_behavior {
    target_origin_id = "origin-${element(keys(var.records_wr), count.index )}"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 1200
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.records_wr[count.index].certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

}
