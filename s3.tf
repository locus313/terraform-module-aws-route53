# tfsec:ignore:AWS002 - S3 bucket encryption not required for redirect-only buckets (no data stored)
# tfsec:ignore:AWS017 - Bucket encryption not required for redirect-only use case
# tfsec:ignore:AWS077 - Versioning not required for redirect-only buckets (no objects stored)
# tfsec:ignore:AWS098 - Access logging not required for redirect-only buckets
resource "aws_s3_bucket" "records_wr" {
  for_each = var.records_wr

  bucket = each.key
}

resource "aws_s3_bucket_website_configuration" "records_wr" {
  for_each = var.records_wr

  bucket = aws_s3_bucket.records_wr[each.key].id

  # Configure bucket to redirect all requests to the target URL
  redirect_all_requests_to {
    host_name = each.value
    protocol  = "https"
  }
}

resource "aws_s3_bucket_policy" "records_wr" {
  for_each = var.records_wr

  bucket = aws_s3_bucket.records_wr[each.key].id

  # Allow CloudFront to access the S3 bucket using custom User-Agent header as authentication
  # This acts as a shared secret to prevent direct S3 website endpoint access
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.records_wr[each.key].arn}/*"
        Condition = {
          StringEquals = {
            "aws:UserAgent" = base64sha512("REFER-SECRET-19265125-${each.key}-43568442")
          }
        }
      }
    ]
  })
}
