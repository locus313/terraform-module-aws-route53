package test

import (
  "testing"
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
}
