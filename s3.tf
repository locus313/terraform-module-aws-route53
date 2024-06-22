#tfsec:ignore:AWS002 tfsec:ignore:AWS017 tfsec:ignore:AWS077 tfsec:ignore:AWS098
resource "aws_s3_bucket" "records_wr" {
  for_each = var.records_wr
  bucket   = each.key
}

resource "aws_s3_bucket_website_configuration" "records_wr" {
  for_each = var.records_wr
  bucket   = aws_s3_bucket.records_wr[each.key].id

  redirect_all_requests_to {
    host_name = each.value
    protocol  = "https"
  }
}
