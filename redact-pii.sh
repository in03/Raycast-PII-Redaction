#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Redact PII
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🙈
# @raycast.argument1 { "type": "text", "placeholder": "Text or clipboard", "optional": true }
# @raycast.packageName PII Tools

# Documentation:
# @raycast.description Redact PII from text using spaCy NER
# @raycast.author Caleb Trevatt
# @raycast.authorURL https://github.com/in03

set -euo pipefail

# Get input text from argument or clipboard
if [ -n "${1:-}" ]; then
    input_text="$1"
else
    input_text=$(pbpaste)
fi

if [ -z "$input_text" ]; then
    echo "❌ No input text provided"
    exit 1
fi

# Use full path to uvx to run the Python script with dependencies
result=$(echo "$input_text" | /Users/caleb/.local/bin/uvx --from ./pii-redaction pii-redactor redact --output-format text)

if [ $? -eq 0 ]; then
    # Copy redacted text to clipboard
    echo "$result" | pbcopy
    echo "✅ PII redacted and copied to clipboard"
else
    echo "❌ Failed to redact PII"
    exit 1
fi 