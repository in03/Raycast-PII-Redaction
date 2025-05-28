#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Reverse PII Redaction
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon ↩️
# @raycast.argument1 { "type": "text", "placeholder": "Text or clipboard", "optional": true }
# @raycast.packageName PII Tools

# Documentation:
# @raycast.description Reverse PII redaction using stored mapping
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

# Check if mapping file exists
mapping_file="$HOME/.raycast-pii-mapping.json"
if [ ! -f "$mapping_file" ]; then
    echo "❌ No PII mapping found. Please redact some text first."
    exit 1
fi

# Use uvx to run the Python script with dependencies
result=$(echo "$input_text" | uvx --from . pii_redactor.py reverse --output-format text)

if [ $? -eq 0 ]; then
    # Copy restored text to clipboard
    echo "$result" | pbcopy
    echo "✅ PII restored and copied to clipboard"
else
    echo "❌ Failed to reverse redaction"
    exit 1
fi 