resource "aws_s3_bucket" "records_wr" {
  count      = length(keys(var.records_wr))
  bucket     = element(keys(var.records_wr), count.index )

  website {
    redirect_all_requests_to = element(values(var.records_wr), count.index)
  }
}
