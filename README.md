# Route53 Terraform module

Terraform module which creates Route53 resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.49 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.49 |
| <a name="provider_aws.acm"></a> [aws.acm](#provider\_aws.acm) | >= 2.49 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.records_wr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.records_wr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.records_wr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_route53_record.records_a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.records_caa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.records_cname](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.records_mx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.records_ns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.records_txt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.records_wr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.records_wr_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_s3_bucket.records_wr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_website_configuration.records_wr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_primary_domain"></a> [primary\_domain](#input\_primary\_domain) | Route53 Primary domain | `any` | n/a | yes |
| <a name="input_records_a"></a> [records\_a](#input\_records\_a) | Map of A records separate by comma (,) | `map` | `{}` | no |
| <a name="input_records_caa"></a> [records\_caa](#input\_records\_caa) | Map of CAA records separate by comma (,) | `map` | `{}` | no |
| <a name="input_records_cname"></a> [records\_cname](#input\_records\_cname) | Map of CNAME records separate by comma (,) | `map` | `{}` | no |
| <a name="input_records_mx"></a> [records\_mx](#input\_records\_mx) | Map of MX records separate by comma (,) | `map` | `{}` | no |
| <a name="input_records_ns"></a> [records\_ns](#input\_records\_ns) | Map of NS records separate by comma (,) | `map` | `{}` | no |
| <a name="input_records_txt"></a> [records\_txt](#input\_records\_txt) | Map of TXT records separate by comma (,) | `map` | `{}` | no |
| <a name="input_records_wr"></a> [records\_wr](#input\_records\_wr) | Map of redirect records | `map` | `{}` | no |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | Default TTL for All records | `number` | `"3600"` | no |
| <a name="input_ttl_acm"></a> [ttl\_acm](#input\_ttl\_acm) | Default TTL for acm records | `number` | `"60"` | no |
| <a name="input_ttl_ns"></a> [ttl\_ns](#input\_ttl\_ns) | Default TTL for ns records | `number` | `"172800"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_this_route53_zone_name_servers"></a> [this\_route53\_zone\_name\_servers](#output\_this\_route53\_zone\_name\_servers) | Name servers of Route53 zone |
| <a name="output_this_route53_zone_zone_id"></a> [this\_route53\_zone\_zone\_id](#output\_this\_route53\_zone\_zone\_id) | Zone ID of Route53 zone |
<!-- END_TF_DOCS -->

## Usage

### Create Route53 zones and records

```hcl
module "example-com" {
   source = "git@github.com:locus313/terraform-module-aws-route53.git"
   
   primary_domain                                              = "example.com"
   
   records_wr = {
     "support.example.com"                                     = "https://example.atlassian.net/servicedesk/customer/portals"
   }
   
   records_a = {
     "example.com"                                             = ["12.23.45.56"]
   }

   records_caa = {
     "example.com"                                             = ["0 issue \"letsencrypt.org\""]
   }
   
   records_cname = {
     "calendar.example.com"                                    = ["ghs.googlehosted.com"]
     "docs.example.com"                                        = ["ghs.googlehosted.com"]
     "ftp.example.com"                                         = ["example.com"]
     "mail.example.com"                                        = ["ghs.googlehosted.com"]
     "sites.example.com"                                       = ["ghs.googlehosted.com"]
     "www.example.com"                                         = ["example.com"]
   }
   
   records_mx = {
     "example.com"                                             = ["10 aspmx.l.google.com","20 alt1.aspmx.l.google.com","30 alt2.aspmx.l.google.com","40 aspmx2.googlemail.com","50 aspmx3.googlemail.com"]
   }
   
   records_txt = {
     "example.com"                                             = ["v=spf1 include:_spf.google.com ~all"]
     "google._domainkey.example.com"                           = ["v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3gtOkCHXv+kDJBpIkr1lq1Ywd4B8FJGPceSv9s7yhUtCk8pKwifLmSKWNEyOvuK5oxIms+4Vc9Pu46bi/wehi5zJynzhkOrzYXdOX6+m4Nb8NbFWr0zZqsM+pDGmYzRjeczY/+txXnOegcbxL+967bIRisnlH2CRD91h1t0NJwsvvN23T5MAMaeJr726piDdE\"\"C6P2nF1apYbGXp0DZGz/RvtpCGjASjlpejA8I/xLclZOBn4Ir9pk8gajRSG48D21UKJ3d+PFzYEj9X5n1p1i2trjCqkdyCzU+f3vTUxma5F7fQncKYIeRJwVNbmR03IYfGuicCu13hnVP36aT5yuQIDAQAB"]
   }
   
   records_ns = {
     "clusters.example.com"                                    = ["ns-128.awsdns-16.com","ns-1533.awsdns-63.org","ns-1554.awsdns-02.co.uk","ns-956.awsdns-55.net"]
     "envs.example.com"                                        = ["ns-1103.awsdns-09.org","ns-1587.awsdns-06.co.uk","ns-378.awsdns-47.com","ns-693.awsdns-22.net"]
   }
}

```

Note that `depends_on` in modules is available since Terraform 0.13.

## DNS record types

Supported record types as follows:

| Record type   | Supported |
| ------------- | ---------- |
| A             | YES        |
| AAAA          | NO         |
| CAA           | YES        |
| CNAME         | YES        |
| LOC           | NO         |
| MX            | YES        |
| NS            | YES        |
| PTR           | NO         |
| SOA           | NO         |
| SRV           | NO         |
| SPF           | NO         |
| TXT           | YES        |

## Authors

Module managed by [Patrick Lewis](https://github.com/locus313).
