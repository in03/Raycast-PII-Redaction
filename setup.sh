#!/bin/bash
# Setup script for PII Redactor

set -euo pipefail

echo "🚀 Setting up PII Redactor..."

# Check if uvx is installed
if ! command -v uvx &> /dev/null; then
    echo "❌ uvx is not installed. Please install it first:"
    echo "   pip install uv"
    exit 1
fi

# Confirm correct installation location
echo ""
echo "Continuing will install pii-redaction scripts."
echo "Please confirm this directory (pii-redaction) is placed directly in your Raycast scripts folder, without any modifications to the structure."
echo ""
read -p "Is this correct? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Please move this directory to your Raycast scripts folder first."
    exit 1
fi

# Install spaCy model using uv tool run with pip
echo "📦 Installing spaCy English model..."
uv tool run --with pip spacy download en_core_web_sm

# Make Raycast scripts executable
echo "🔧 Making Raycast scripts executable..."
chmod +x ./redact-pii.sh
chmod +x ./reverse-redaction.sh
# Create symlinks to script files
echo "🔗 Creating symlinks to script files..."
ln -sf "$(pwd)/redact-pii.sh" ../redact-pii.sh
ln -sf "$(pwd)/reverse-redaction.sh" ../reverse-redaction.sh


echo "✅ Setup complete!"
echo ""
echo "Now just run 'Reload Script Directories' in Raycast!"
echo ""
echo "Usage:"
echo "- 'Redact PII' command: Redacts PII from clipboard or input text"
echo "- 'Reverse PII Redaction' command: Restores original text using stored mapping"