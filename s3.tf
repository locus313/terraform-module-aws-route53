#tfsec:ignore:AWS002 tfsec:ignore:AWS017 tfsec:ignore:AWS077 tfsec:ignore:AWS098
resource "aws_s3_bucket" "records_wr" {
  for_each   = var.records_wr
  bucket     = each.key

  website {
    redirect_all_requests_to = each.value
  }
}
