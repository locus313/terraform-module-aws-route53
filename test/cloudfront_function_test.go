package test

import (
	"os"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestRedirectFunctionTemplate guards against a regression where the CloudFront
// Function prepended its own "https://" and appended the viewer's request path,
// turning a full destination URL into a broken "https://https://..." redirect.
func TestRedirectFunctionTemplate(t *testing.T) {
	raw, err := os.ReadFile("../templates/redirect-function.js.tftpl")
	require.NoError(t, err)

	targetURL := "https://example.atlassian.net/servicedesk"
	rendered := strings.ReplaceAll(string(raw), "${target_url}", targetURL)

	assert.Contains(t, rendered, "value: '"+targetURL+"'")
	assert.NotContains(t, rendered, "https://"+targetURL)
	assert.NotContains(t, rendered, "request.uri")
}
