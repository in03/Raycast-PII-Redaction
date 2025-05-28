# PII Redactor

A simple, standalone PII redaction tool using spaCy NER, designed for use with Raycast scripts via `uvx`.

## Features

- **Reversible Redaction**: Replaces PII with labeled placeholders (e.g., `[PERSON_1]`, `[ORG_2]`) instead of generic `[REDACTED]`
- **Mapping Storage**: Stores redaction mapping locally for reversal
- **Raycast Integration**: Bash scripts that work seamlessly with Raycast
- **Zero Setup**: Uses `uvx` to handle Python dependencies automatically

## Supported PII Types

- **PERSON**: Names of people
- **ORG**: Organizations, companies
- **GPE**: Geopolitical entities (countries, cities, states)
- **LOC**: Locations
- **DATE**: Dates
- **EMAIL**: Email addresses (if detected)
- **PHONE**: Phone numbers (if detected)
- **SSN**: Social Security Numbers (if detected)

## Quick Start

1. **Install uv** (if not already installed):
   ```bash
   pip install uv
   ```

2. **Run setup**:
   ```bash
   ./setup.sh
   ```

3. **Follow instructions**:
   - Setup.sh will provide further instructions:
      - Copy the `.sh` files to your Raycast scripts directory, or
      - Add this directory to your Raycast script paths
      - Refresh Raycast scripts

## Usage

### Via Raycast

1. **Redact PII**: 
   - Run "Redact PII" command
   - Input text or leave empty to use clipboard
   - Redacted text is copied to clipboard

2. **Reverse Redaction**:
   - Run "Reverse PII Redaction" command  
   - Input redacted text or leave empty to use clipboard
   - Original text is restored and copied to clipboard

### Via Command Line

```bash
# Redact PII from text
echo "John Smith works at Microsoft" | uvx --from . pii_redactor.py redact --output-format text

# Redact and get full JSON output
echo "John Smith works at Microsoft" | uvx --from . pii_redactor.py redact

# Reverse redaction
echo "[PERSON_1] works at [ORG_1]" | uvx --from . pii_redactor.py reverse --output-format text
```

## Example

**Input:**
```
John Smith works at Microsoft in Seattle. Contact him at john@microsoft.com on 2024-01-15.
```

**Redacted:**
```
[PERSON_1] works at [ORG_1] in [GPE_1]. Contact him at [EMAIL_1] on [DATE_1].
```

**Mapping (stored in `~/.raycast-pii-mapping.json`):**
```json
{
  "[PERSON_1]": {
    "original_text": "John Smith",
    "entity_type": "PERSON",
    "start_char": 0,
    "end_char": 10
  },
  "[ORG_1]": {
    "original_text": "Microsoft", 
    "entity_type": "ORG",
    "start_char": 20,
    "end_char": 29
  }
}
```

## How It Works

1. **uvx Magic**: The bash scripts use `uvx --from .` to automatically:
   - Install spaCy and dependencies in an isolated environment
   - Run the Python script with the correct interpreter
   - Handle all dependency management

2. **Single Mapping**: Only stores the most recent redaction mapping (simple clipboard approach)

3. **Position-Aware**: Processes entities in reverse order to maintain accurate character positions during replacement

## Files

- `pii_redactor.py` - Main Python script with redaction logic
- `pyproject.toml` - Dependencies and project configuration
- `raycast-redact-pii.sh` - Raycast script for redaction
- `raycast-reverse-redaction.sh` - Raycast script for reversal
- `setup.sh` - One-time setup script

## Why This Approach?

- **No LangFlow overhead** for simple NER tasks
- **uvx handles dependencies** automatically
- **Raycast-compatible** bash scripts
- **Simple and reliable** workflow
- **Easy to modify** and extend

## Troubleshooting

**"spaCy model not found"**: Run the setup script to install the English model:
```bash
./setup.sh
```

**"uvx not found"**: Install uv first:
```bash
pip install uv
```

**"No PII mapping found"**: You need to redact some text first before you can reverse redaction.
