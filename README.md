# Route53 Terraform module

Terraform module which creates Route53 resources.

* * *

## Terraform versions

Terraform 0.12.6.

* * *
## Usage

### Create Route53 zones and records

```hcl
module "modusbox-com" {
   source = "git@github.com:modusintegration/terraform-module-aws-route53.git"
   
   primary_domain                                              = "example.com"
   
   sub_domain = {
     "clusters.example.com"                                    = "clusters.example.com"
     "envs.example.com"                                        = "envs.example.com"
   }
   
   records_wr = {
     "support.example.com"                                     = "https://example.atlassian.net/servicedesk/customer/portals"
   }
   
   records_a = {
     "example.com"                                             = ["12.23.45.56"]
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

* * *

## Examples

* [Route53 records example](https://github.com/modusintegration/aws-it-account-terraform/blob/master/modules/dns/modusbox-com.tf) which shows how to create Route53 records.

* * *

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.6, < 0.14 |
| aws | >= 2.49, < 4.0 |

## DNS record types

Supported record types as follows:

| Record type   | Supported |
| ------------- | ---------- |
| A             | YES        |
| AAAA          | NO         |
| CAA           | NO         |
| CNAME         | YES        |
| LOC           | NO         |
| MX            | YES        |
| NS            | YES        |
| PTR           | NO         |
| SOA           | NO         |
| SRV           | NO         |
| SPF           | NO         |
| TXT           | YES        |

* * *

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.49 |

* * *

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| primary\_domain | Route53 Primary domain | `any` |  | yes |
| sub\_domain | Map of Route53 sub domains | `any` | `null` | no |
| ttl | Default TTL for All records | `number` | `3600` | no |
| ttl\_acm | Default TTL for acm records | `number` | `60` | no |
| records\_a | Map of A records separate by comma (,) | `map` | `{}` | no |
| records\_cname | Map of CNAME records separate by comma(,) | `map` | `{}` | no |
| records\_mx | Map of MX records separate by comma (,) | `map` | `{}` | no |
| records\_txt | Map of TXT records separate by comma (,) | `map` | `{}` | no |
| records\_ns | Map of NS records separate by comma (,) | `map` | `{}` | no |
| records\_wr | Map of redirect records | `map` | `{}` | no |

* * *

## Outputs

| Name | Description |
|------|-------------|
| this\_route53\_zone\_zone\_id | Zone ID of Route53 zone |
| this\_route53\_zone\_name\_servers | Name servers of Route53 zone |

* * *

## Authors

Module managed by [Patrick Lewis](https://github.com/locus313).
