Feature: Route 53 Compliance

  Scenario: Ensure all A records have the correct TTL
    Given I have aws_route53_record defined
    When its type is "A"
    Then its ttl must be 3600

  Scenario: Ensure all CNAME records have the correct TTL
    Given I have aws_route53_record defined
    When its type is "CNAME"
    Then its ttl must be 3600
