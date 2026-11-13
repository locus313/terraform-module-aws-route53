package test

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// requireTool skips locally when a tool is missing but fails in CI, so a broken
// runner cannot silently disable these tests.
func requireTool(t *testing.T, name string) {
	if _, err := exec.LookPath(name); err != nil {
		if os.Getenv("CI") != "" {
			t.Fatalf("%s is required in CI", name)
		}
		t.Skipf("%s not available", name)
	}
}

// render renders the redirect template through real Terraform templatefile().
func render(t *testing.T, targetURL string, preservePath bool) string {
	requireTool(t, "terraform")
	tpl, err := filepath.Abs("../templates/redirect-function.js.tftpl")
	require.NoError(t, err)

	dir := t.TempDir()
	cfg := fmt.Sprintf(`output "code" {
  value = templatefile(%q, { target_url = %q, preserve_path = %t })
}
`, tpl, targetURL, preservePath)
	require.NoError(t, os.WriteFile(filepath.Join(dir, "main.tf"), []byte(cfg), 0o600))

	for _, args := range [][]string{{"init", "-input=false"}, {"apply", "-auto-approve", "-input=false"}} {
		cmd := exec.Command("terraform", args...)
		cmd.Dir = dir
		out, err := cmd.CombinedOutput()
		require.NoError(t, err, string(out))
	}
	cmd := exec.Command("terraform", "output", "-raw", "code")
	cmd.Dir = dir
	out, err := cmd.Output()
	require.NoError(t, err)
	return string(out)
}

// location runs the rendered CloudFront Function in node and returns the Location header.
func location(t *testing.T, code, event string) string {
	requireTool(t, "node")
	script := code + "\nconsole.log(handler(" + event + ").headers.location.value)"
	out, err := exec.Command("node", "-e", script).CombinedOutput()
	require.NoError(t, err, string(out))
	return strings.TrimSpace(string(out))
}

// Guards against the function prepending "https://" to a full destination URL.
func TestRedirectFunctionTemplate(t *testing.T) {
	targetURL := "https://example.atlassian.net/servicedesk"
	rendered := render(t, targetURL, false)

	assert.Contains(t, rendered, "var target = '"+targetURL+"'")
	assert.NotContains(t, rendered, "https://"+targetURL)
	assert.NotContains(t, rendered, "request.uri")
	assert.Equal(t, targetURL, location(t, rendered, `{request:{uri:"/a",querystring:{}}}`))
}

func TestRedirectFunctionPreservePath(t *testing.T) {
	rendered := render(t, "https://www.example.com/de/", true)

	assert.Equal(t, "https://www.example.com/de/ressource/x",
		location(t, rendered, `{request:{uri:"/ressource/x",querystring:{}}}`))
	assert.Equal(t, "https://www.example.com/de",
		location(t, rendered, `{request:{uri:"/",querystring:{}}}`))
	assert.Equal(t, "https://www.example.com/de/a?b=1&c=2",
		location(t, rendered, `{request:{uri:"/a",querystring:{b:{value:"1"},c:{value:"2"}}}}`))
}
