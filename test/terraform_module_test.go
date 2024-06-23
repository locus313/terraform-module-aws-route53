package test

import (
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/route53"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformRoute53Module(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../example",
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	zoneID := terraform.Output(t, terraformOptions, "zone_id")
	assert.NotEmpty(t, zoneID)

	validateARecord(t, zoneID, "lo5t.dev", "12.23.45.56")
}

func validateARecord(t *testing.T, zoneID, recordName, expectedIP string) {
	sess := session.Must(session.NewSession())
	svc := route53.New(sess)

	resp, err := svc.ListResourceRecordSets(&route53.ListResourceRecordSetsInput{
		HostedZoneId: aws.String(zoneID),
	})
	assert.NoError(t, err)

	var found bool
	for _, recordSet := range resp.ResourceRecordSets {
		if aws.StringValue(recordSet.Name) == recordName && aws.StringValue(recordSet.Type) == "A" {
			assert.Len(t, recordSet.ResourceRecords, 1)
			assert.Equal(t, expectedIP, aws.StringValue(recordSet.ResourceRecords[0].Value))
			found = true
		}
	}
	assert.True(t, found, "A record not found: %s", recordName)
}
