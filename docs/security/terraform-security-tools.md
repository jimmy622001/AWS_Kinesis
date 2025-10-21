# Terraform Security Tools

This document outlines the security scanning tools implemented in this AWS Kinesis project to ensure secure infrastructure as code.

## Implemented Tools

| Tool | Purpose | When It Runs | Severity Levels |
|------|---------|--------------|----------------|
| **Checkov** | Scans for cloud misconfigurations and security issues | Pre-commit, CI/CD | Low, Medium, High, Critical |
| **TFLint** | Validates Terraform code quality and AWS best practices | Pre-commit, CI/CD | Error, Warning, Notice |
| **KICS** | Finds security vulnerabilities, compliance issues | CI/CD | High, Medium, Low, Info |
| **Terrascan** | Policy-as-code security scanner | Local scans | High, Medium, Low |

## Local Development Setup

### Prerequisites

Install the required tools:

```bash
# Install pre-commit
pip install pre-commit

# Install TFLint
brew install tflint  # macOS
# or
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash  # Linux

# Install Checkov
pip install checkov

# Install KICS
brew install kics  # macOS
# or follow instructions at https://github.com/Checkmarx/kics/releases

# Install Terrascan
brew install terrascan  # macOS
# or
curl -L "$(curl -s https://api.github.com/repos/accurics/terrascan/releases/latest | grep -o -E "https://.+?_Darwin_x86_64.tar.gz")" > terrascan.tar.gz && tar -xf terrascan.tar.gz terrascan && rm terrascan.tar.gz && sudo mv terrascan /usr/local/bin/  # macOS
```

### Using Pre-commit Hooks

After installation, set up the pre-commit hooks:

```bash
pre-commit install
```

Now, each time you commit changes, the security scans will run automatically.

## Running Security Scans Manually

Use the provided script to run all security scans:

```bash
# Make script executable
chmod +x scripts/security-scan.sh

# Run the script
./scripts/security-scan.sh
```

## CI/CD Integration

Security scans are automatically run in CI/CD pipelines:

1. On push to main/master/develop branches
2. On pull requests to these branches
3. Manually via workflow dispatch

Results are available in the GitHub Actions tab and as comments on pull requests.

## Common Security Issues and Remediation

### Exposed Secrets

**Issue**: Hardcoded API keys, passwords, or tokens in Terraform code.
**Fix**: Use AWS Secrets Manager or Parameter Store and reference them securely.

Example:
```terraform
# Bad
resource "aws_kinesis_stream" "example" {
  name         = "example-stream"
  access_key   = "AKIAIOSFODNN7EXAMPLE"  # EXPOSED SECRET!
}

# Good
data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "kinesis/api-keys"
}

locals {
  creds = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
}

resource "aws_kinesis_stream" "example" {
  name       = "example-stream"
  access_key = local.creds.access_key
}
```

### Unencrypted Data Storage

**Issue**: Unencrypted Kinesis streams or S3 buckets.
**Fix**: Enable encryption at rest and in transit.

Example:
```terraform
# Good practice
resource "aws_kinesis_stream" "example" {
  name            = "example-stream"
  shard_count     = 1
  encryption_type = "KMS"
  kms_key_id      = aws_kms_key.kinesis.arn
}
```

### Over-permissive IAM Roles

**Issue**: IAM roles with wildcard permissions.
**Fix**: Follow the principle of least privilege.

Example:
```terraform
# Bad
resource "aws_iam_policy" "bad_policy" {
  policy = jsonencode({
    Statement = [{
      Action   = "*"  # TOO PERMISSIVE!
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

# Good
resource "aws_iam_policy" "good_policy" {
  policy = jsonencode({
    Statement = [{
      Action   = [
        "kinesis:PutRecord",
        "kinesis:PutRecords",
        "kinesis:DescribeStream"
      ]
      Effect   = "Allow"
      Resource = aws_kinesis_stream.example.arn
    }]
  })
}
```

## Security Best Practices for AWS Kinesis

1. **Encryption**: Always encrypt data at rest and in transit
2. **Access Control**: Implement fine-grained IAM policies
3. **Monitoring**: Enable CloudWatch monitoring for abnormal activity
4. **Network Security**: Use VPC endpoints to keep traffic private
5. **Data Validation**: Validate data before ingestion to prevent injection attacks

## References

- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [AWS Kinesis Security](https://docs.aws.amazon.com/streams/latest/dev/security.html)
- [Checkov Documentation](https://www.checkov.io/1.Welcome/Quick%20Start.html)
- [TFLint Rules](https://github.com/terraform-linters/tflint/blob/master/docs/rules/README.md)