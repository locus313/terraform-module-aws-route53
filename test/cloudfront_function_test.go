package test

import (
	"os"
	"os/exec"
	"regexp"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// render emulates templatefile() for the redirect template: it substitutes
// target_url and resolves the preserve_path %{ if } block.
func render(t *testing.T, targetURL string, preservePath bool) string {
	raw, err := os.ReadFile("../templates/redirect-function.js.tftpl")
	require.NoError(t, err)

	block := regexp.MustCompile(`(?s)%\{ if preserve_path ~\}\n(.*?)%\{ endif ~\}\n`)
	out := string(raw)
	if preservePath {
		out = block.ReplaceAllString(out, "$1")
	} else {
		out = block.ReplaceAllString(out, "")
	}
	return strings.ReplaceAll(out, "${target_url}", targetURL)
}

// location runs the rendered CloudFront Function in node and returns the Location header.
func location(t *testing.T, code, event string) string {
	if _, err := exec.LookPath("node"); err != nil {
		t.Skip("node not available")
	}
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
