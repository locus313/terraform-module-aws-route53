Feature: Route 53 Compliance

  Scenario: Ensure all A records have the correct TTL
    Given I have aws_route53_record defined
    When its type is "A"
    And it does not have alias
    Then its ttl must be 3600

  Scenario: Ensure all AAAA records have the correct TTL
    Given I have aws_route53_record defined
    When its type is "AAAA"
    Then its ttl must be 3600

  Scenario: Ensure all CNAME records have the correct TTL
    Given I have aws_route53_record defined
    When its type is "CNAME"
    Then its ttl must be 3600

  Scenario: Ensure all MX records have the correct TTL
    Given I have aws_route53_record defined
    When its type is "MX"
    Then its ttl must be 3600

  Scenario: Ensure all TXT records have the correct TTL
    Given I have aws_route53_record defined
    When its type is "TXT"
    Then its ttl must be 3600

  Scenario: Ensure all CAA records have the correct TTL
    Given I have aws_route53_record defined
    When its type is "CAA"
    Then its ttl must be 3600

  Scenario: Ensure all NS records have the correct TTL
    Given I have aws_route53_record defined
    When its type is "NS"
    Then its ttl must be 172800

  Scenario: Ensure ACM validation records have short TTL
    Given I have aws_route53_record defined
    When its name contains records_wr_validation
    Then its ttl must be 60

  Scenario: Ensure CloudFront distributions use SNI
    Given I have aws_cloudfront_distribution defined
    Then it must have viewer_certificate
    And its ssl_support_method must be sni-only

  Scenario: Ensure CloudFront uses minimum TLSv1.2
    Given I have aws_cloudfront_distribution defined
    Then it must have viewer_certificate
    And its minimum_protocol_version must be TLSv1.2_2021
