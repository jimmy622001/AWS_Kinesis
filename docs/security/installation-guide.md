# Security Tools Installation Guide

This guide provides step-by-step instructions for setting up the security tools for this AWS Kinesis Terraform project.

## Installing Required Tools

### Pre-commit

Pre-commit is a framework for managing and maintaining pre-commit hooks.

**Installation:**

```bash
# Using pip
pip install pre-commit

# Or using Homebrew on macOS
brew install pre-commit
```

**Setup:**

After installation, run this command in the project root:

```bash
pre-commit install
```

This will set up the git hook scripts defined in `.pre-commit-config.yaml`.

### TFLint

TFLint is a Terraform linter focused on detecting errors and enforcing best practices.

**Installation:**

```bash
# macOS (Homebrew)
brew install tflint

# Linux
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Windows
choco install tflint
```

**Usage:**

```bash
# Run in project root
tflint --config=.tflint.hcl
```

### Checkov

Checkov is a static code analysis tool for infrastructure as code.

**Installation:**

```bash
# Using pip
pip install checkov

# Or using Homebrew on macOS
brew install checkov
```

**Usage:**

```bash
# Run in project root
checkov --directory . --framework terraform
```

### KICS

KICS (Keeping Infrastructure as Code Secure) is an open-source solution for static code analysis.

**Installation:**

```bash
# macOS (Homebrew)
brew install kics

# Docker
docker pull checkmarx/kics:latest
```

**Usage:**

```bash
# Direct installation
kics scan -p . --platform terraform

# Docker
docker run -v ${PWD}:/path checkmarx/kics:latest scan -p /path --platform terraform
```

### Terrascan

Terrascan is a static code analyzer for infrastructure as code.

**Installation:**

```bash
# macOS (Homebrew)
brew install terrascan

# Linux and MacOS
curl -L "$(curl -s https://api.github.com/repos/accurics/terrascan/releases/latest | grep -o -E "https://.+?_Darwin_x86_64.tar.gz")" > terrascan.tar.gz
tar -xf terrascan.tar.gz terrascan
rm terrascan.tar.gz
sudo mv terrascan /usr/local/bin/
```

**Usage:**

```bash
# Run in project root
terrascan scan -d . -o human
```

## VS Code Extensions

For a better development experience, install these VS Code extensions:

1. **HashiCorp Terraform**
   - ID: HashiCorp.terraform
   - Features: Syntax highlighting, IntelliSense, code formatting

2. **Checkov**
   - ID: bridgecrew.checkov
   - Features: Real-time security scanning

3. **TFLint**
   - ID: terraform-linters.tflint-vscode
   - Features: Linting and rule violation highlighting

## IDE Configuration (VS Code)

Add these settings to your VS Code workspace settings:

```json
{
  "editor.formatOnSave": true,
  "[terraform]": {
    "editor.defaultFormatter": "hashicorp.terraform",
    "editor.formatOnSave": true
  },
  "terraform.languageServer.enable": true,
  "terraform.validation.enable": true,
  "terraform.experimentalFeatures.validateOnSave": true
}
```

## GitHub Repository Configuration

For GitHub repositories, ensure branch protection rules are set up:

1. Go to Repository Settings > Branches > Branch protection rules
2. Create a rule for your main branch
3. Enable "Require status checks to pass before merging"
4. Add the security scan workflow as a required check

## Troubleshooting

### Common Issues

1. **Pre-commit errors during installation**

   If you encounter Python-related errors, ensure you have the correct Python version:
   ```bash
   python --version  # Should be 3.7+
   ```

2. **TFLint plugin load failures**

   If plugins fail to load, manually initialize them:
   ```bash
   tflint --init
   ```

3. **Terraform validate failures**

   If terraform validate fails despite correct code:
   ```bash
   terraform init -backend=false
   terraform validate
   ```

### Getting Help

If you encounter any issues with the security tools:

1. Check the tool's documentation:
   - [Checkov Documentation](https://www.checkov.io/1.Welcome/Quick%20Start.html)
   - [TFLint GitHub](https://github.com/terraform-linters/tflint)
   - [KICS Documentation](https://docs.kics.io/)
   - [Terrascan Documentation](https://docs.accurics.com/projects/accurics-terrascan/en/latest/)

2. Review our internal documentation:
   - [Terraform Security Best Practices](./terraform-security-tools.md)
   - Security team contact: security@company.com
