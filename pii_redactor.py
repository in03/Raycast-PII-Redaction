#!/usr/bin/env python3
"""
Standalone PII redactor using spaCy
Designed to be called via uvx from Raycast bash scripts
"""

import spacy
import json
import sys
import argparse
from pathlib import Path

def redact_pii(input_text: str) -> dict:
    """
    Redact PII from input text using spaCy NER
    Returns dict with redacted text and mapping for reversal
    """
    try:
        nlp = spacy.load("en_core_web_sm")
    except OSError:
        print("Error: spaCy model 'en_core_web_sm' not found.", file=sys.stderr)
        print("Install with: python -m spacy download en_core_web_sm", file=sys.stderr)
        sys.exit(1)
    
    doc = nlp(input_text)
    redacted_text = input_text
    pii_mapping = {}
    entity_counters = {}
    
    # Sort entities by position (reverse order to maintain text positions during replacement)
    entities = sorted(doc.ents, key=lambda x: x.start_char, reverse=True)
    
    for ent in entities:
        if ent.label_ in ["PERSON", "GPE", "EMAIL", "ORG", "LOC", "DATE", "PHONE", "SSN"]:
            # Create counter for each entity type
            if ent.label_ not in entity_counters:
                entity_counters[ent.label_] = 0
            entity_counters[ent.label_] += 1
            
            # Create placeholder with entity type and counter
            placeholder = f"[{ent.label_}_{entity_counters[ent.label_]}]"
            
            # Store mapping for reversal
            pii_mapping[placeholder] = {
                "original_text": ent.text,
                "entity_type": ent.label_,
                "start_char": ent.start_char,
                "end_char": ent.end_char
            }
            
            # Replace in text (working backwards preserves character positions)
            redacted_text = redacted_text[:ent.start_char] + placeholder + redacted_text[ent.end_char:]
    
    return {
        "redacted_text": redacted_text,
        "pii_mapping": pii_mapping,
        "original_length": len(input_text),
        "redacted_length": len(redacted_text),
        "entity_count": len(pii_mapping)
    }

def reverse_redaction(redacted_text: str, mapping_file: str) -> str:
    """
    Reverse PII redaction using stored mapping
    """
    try:
        with open(mapping_file, 'r') as f:
            pii_mapping = json.load(f)
    except FileNotFoundError:
        print(f"Error: Mapping file {mapping_file} not found.", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON in mapping file {mapping_file}.", file=sys.stderr)
        sys.exit(1)
    
    restored_text = redacted_text
    
    # Replace placeholders with original text
    for placeholder, info in pii_mapping.items():
        restored_text = restored_text.replace(placeholder, info["original_text"])
    
    return restored_text

def main():
    parser = argparse.ArgumentParser(description="PII Redactor using spaCy")
    parser.add_argument("command", choices=["redact", "reverse"], help="Command to execute")
    parser.add_argument("--input", "-i", help="Input text (if not provided, reads from stdin)")
    parser.add_argument("--mapping-file", "-m", default=str(Path.home() / ".raycast-pii-mapping.json"), 
                       help="Path to mapping file (default: ~/.raycast-pii-mapping.json)")
    parser.add_argument("--output-format", "-f", choices=["json", "text"], default="json",
                       help="Output format (default: json)")
    
    args = parser.parse_args()
    
    # Get input text
    if args.input:
        input_text = args.input
    else:
        input_text = sys.stdin.read().strip()
    
    if not input_text:
        print("Error: No input text provided.", file=sys.stderr)
        sys.exit(1)
    
    if args.command == "redact":
        result = redact_pii(input_text)
        
        # Save mapping to file
        with open(args.mapping_file, 'w') as f:
            json.dump(result["pii_mapping"], f, indent=2)
        
        if args.output_format == "json":
            print(json.dumps(result, indent=2))
        else:
            print(result["redacted_text"])
            
    elif args.command == "reverse":
        restored_text = reverse_redaction(input_text, args.mapping_file)
        
        if args.output_format == "json":
            print(json.dumps({"restored_text": restored_text}))
        else:
            print(restored_text)

if __name__ == "__main__":
    main() 