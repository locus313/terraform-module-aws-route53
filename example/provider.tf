provider "aws" {
  region = "us-west-2"
}

# ACM certificates for CloudFront must be created in us-east-1
provider "aws" {
  alias  = "acm"
  region = "us-east-1"
}