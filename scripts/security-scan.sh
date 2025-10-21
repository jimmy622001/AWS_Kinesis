#!/bin/bash
# Security Scanning Script for AWS Kinesis Terraform project
# Usage: ./scripts/security-scan.sh

set -e

echo "===== Running Terraform Format ====="
terraform fmt -recursive
echo ""

echo "===== Running Terraform Validate ====="
terraform validate
echo ""

if command -v tflint &> /dev/null; then
    echo "===== Running TFLint ====="
    tflint --config=.tflint.hcl
    echo ""
else
    echo "TFLint not installed. Install with: brew install tflint or go install github.com/terraform-linters/tflint@latest"
fi

if command -v checkov &> /dev/null; then
    echo "===== Running Checkov ====="
    checkov --directory . --framework terraform --quiet --compact
    echo ""
else
    echo "Checkov not installed. Install with: pip install checkov"
fi

if command -v kics &> /dev/null; then
    echo "===== Running KICS ====="
    kics scan -p . --platform terraform --exclude-paths ".terraform,**/.terraform" --fail-on high
    echo ""
else
    echo "KICS not installed. Follow installation instructions at: https://github.com/Checkmarx/kics"
fi

if command -v terrascan &> /dev/null; then
    echo "===== Running Terrascan ====="
    terrascan scan -d . -o human
    echo ""
else
    echo "Terrascan not installed. Install with: brew install terrascan or go install github.com/accurics/terrascan/cmd/terrascan@latest"
fi

echo "===== All security scans completed ====="