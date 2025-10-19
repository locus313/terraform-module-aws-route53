#tfsec:ignore:AWS002 tfsec:ignore:AWS017 tfsec:ignore:AWS077 tfsec:ignore:AWS098
resource "aws_s3_bucket" "records_wr" {
  for_each = var.records_wr

  bucket = each.key
}

resource "aws_s3_bucket_website_configuration" "records_wr" {
  for_each = var.records_wr

  bucket = aws_s3_bucket.records_wr[each.key].id

  redirect_all_requests_to {
    host_name = each.value
    protocol  = "https"
  }
}

resource "aws_s3_bucket_policy" "records_wr" {
  for_each = var.records_wr

  bucket = aws_s3_bucket.records_wr[each.key].id

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
