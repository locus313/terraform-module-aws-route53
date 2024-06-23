module "lo5t-dev" {
   source = "locus313/aws-route53/module"
   version = "1.0.5"
   
   enabled                                                     = true
   primary_domain                                              = "lo5t.dev"
   
   records_wr = {
   }
   
   records_a = {
     "lo5t.dev"                                             = ["12.23.45.56"]
   }

   records_aaaa = {
     "lo5t.dev"                                             = ["::ffff:c17:2d38"]
   }

   records_caa = {
     "lo5t.dev"                                             = ["0 issue \"letsencrypt.org\""]
   }
   
   records_cname = {
     "calendar.lo5t.dev"                                    = ["ghs.googlehosted.com"]
     "docs.lo5t.dev"                                        = ["ghs.googlehosted.com"]
     "ftp.lo5t.dev"                                         = ["lo5t.dev"]
     "mail.lo5t.dev"                                        = ["ghs.googlehosted.com"]
     "sites.lo5t.dev"                                       = ["ghs.googlehosted.com"]
     "www.lo5t.dev"                                         = ["lo5t.dev"]
   }
   
   records_mx = {
     "lo5t.dev"                                             = ["10 aspmx.l.google.com","20 alt1.aspmx.l.google.com","30 alt2.aspmx.l.google.com","40 aspmx2.googlemail.com","50 aspmx3.googlemail.com"]
   }
   
   records_txt = {
     "lo5t.dev"                                             = ["v=spf1 include:_spf.google.com ~all"]
     "google._domainkey.lo5t.dev"                           = ["v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3gtOkCHXv+kDJBpIkr1lq1Ywd4B8FJGPceSv9s7yhUtCk8pKwifLmSKWNEyOvuK5oxIms+4Vc9Pu46bi/wehi5zJynzhkOrzYXdOX6+m4Nb8NbFWr0zZqsM+pDGmYzRjeczY/+txXnOegcbxL+967bIRisnlH2CRD91h1t0NJwsvvN23T5MAMaeJr726piDdE\"\"C6P2nF1apYbGXp0DZGz/RvtpCGjASjlpejA8I/xLclZOBn4Ir9pk8gajRSG48D21UKJ3d+PFzYEj9X5n1p1i2trjCqkdyCzU+f3vTUxma5F7fQncKYIeRJwVNbmR03IYfGuicCu13hnVP36aT5yuQIDAQAB"]
   }
   
   records_ns = {
     "clusters.lo5t.dev"                                    = ["ns-128.awsdns-16.com","ns-1533.awsdns-63.org","ns-1554.awsdns-02.co.uk","ns-956.awsdns-55.net"]
     "envs.lo5t.dev"                                        = ["ns-1103.awsdns-09.org","ns-1587.awsdns-06.co.uk","ns-378.awsdns-47.com","ns-693.awsdns-22.net"]
   }
}
