module "example-com" {
   source = "locus313/aws-route53/module"
   version = "1.0.5"
   
   enabled                                                     = true
   primary_domain                                              = "example.com"
   
   records_wr = {
     "support.example.com"                                     = "https://example.atlassian.net/servicedesk/customer/portals"
   }
   
   records_a = {
     "example.com"                                             = ["12.23.45.56"]
   }

   records_aaaa = {
     "example.com"                                             = ["::ffff:c17:2d38"]
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
