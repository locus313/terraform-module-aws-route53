# S3 Bucket for web redirects
# Acts as the CloudFront origin placeholder; redirect logic is handled by the CloudFront Function.
# No objects are ever stored or served - the bucket exists only to satisfy CloudFront's origin requirement.
# tfsec:ignore:AWS002 - Encryption not required for empty placeholder bucket (no data stored)
# tfsec:ignore:AWS017 - Encryption not required for empty placeholder bucket (no data stored)
# tfsec:ignore:AWS077 - Versioning not required for empty placeholder bucket (no objects stored)
# tfsec:ignore:AWS098 - Access logging not required for empty placeholder bucket
resource "aws_s3_bucket" "records_wr" {
  for_each = var.records_wr

  bucket = each.key
}

# Block all public access - bucket is private and accessed only via CloudFront OAC
resource "aws_s3_bucket_public_access_block" "records_wr" {
  for_each = var.records_wr

  bucket = aws_s3_bucket.records_wr[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy granting read access to the specific CloudFront distribution via OAC.
# This is NOT a public policy - it uses aws:SourceArn to restrict access to this
# distribution only, and is unaffected by the block_public_policy setting above.
resource "aws_s3_bucket_policy" "records_wr" {
  for_each = var.records_wr

  bucket = aws_s3_bucket.records_wr[each.key].id

  # Ensure public access block is in place before attaching the bucket policy
  depends_on = [aws_s3_bucket_public_access_block.records_wr]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAC"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.records_wr[each.key].arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = aws_cloudfront_distribution.records_wr[each.key].arn
          }
        }
      }
    ]
  })
}
