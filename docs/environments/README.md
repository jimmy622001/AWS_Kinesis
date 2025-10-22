# AWS Kinesis Environment Methodology

This document describes the environment methodology used in this AWS Kinesis project, explaining how we manage development and production environments with separate configurations while maintaining a unified codebase.

## Table of Contents
- [Environment Strategy Overview](#environment-strategy-overview)
- [Environment Structure](#environment-structure)
- [Configuration Management](#configuration-management)
- [Deployment Workflow](#deployment-workflow)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Environment Strategy Overview

### Two-Environment Approach
This project utilizes a two-environment strategy:

1. **Development Environment (dev)**
   - Used for feature development and testing
   - Configured with reduced resources to minimize costs
   - Connected to non-critical systems

2. **Production Environment (prod)**
   - Used for the actual business operations
   - Fully resourced for optimal performance and reliability
   - Connected to critical business systems

### Benefits of Environment Separation

- **Risk Reduction**: Changes can be tested thoroughly in dev before production deployment
- **Cost Control**: Development environment uses fewer resources to reduce costs
- **Isolation**: Issues in development don't impact production systems
- **Clear Progression Path**: Changes follow dev → prod path with proper reviews

### Implementation Approach

Our implementation uses a single codebase with environment-specific configuration files, allowing us to:
- Maintain consistency between environments
- Reuse infrastructure code
- Easily identify differences between environments
- Automate deployments through environment-specific CI/CD pipelines

## Environment Structure

### Directory Structure

```
/
├── environments/
│   ├── dev/
│   │   ├── terraform.tfvars   # Dev-specific variables
│   │   └── backend.tf         # Dev state configuration
│   └── prod/
│       ├── terraform.tfvars   # Production-specific variables
│       └── backend.tf         # Production state configuration
├── .github/workflows/
│   ├── deploy-dev.yml         # CI/CD pipeline for dev
│   └── deploy-prod.yml        # CI/CD pipeline for prod
└── main.tf                    # Shared infrastructure code
```

### Key Configuration Files

| File | Purpose |
|------|---------|
| `environments/dev/terraform.tfvars` | Contains variables specific to development environment |
| `environments/prod/terraform.tfvars` | Contains variables specific to production environment |
| `environments/dev/backend.tf` | Configures Terraform state storage for dev environment |
| `environments/prod/backend.tf` | Configures Terraform state storage for prod environment |
| `.github/workflows/deploy-dev.yml` | GitHub Actions workflow for deploying to dev |
| `.github/workflows/deploy-prod.yml` | GitHub Actions workflow for deploying to prod |

## Configuration Management

### Variable Management

Our Terraform modules use variables that can be customized for each environment. The main differences include:

#### Development Environment
- **Resource Scaling**: Fewer resources (2 Kinesis shards instead of 10)
- **Data Retention**: Shorter retention period (24 hours vs 7 days)
- **Instance Types**: Smaller, cost-effective instance types
- **Alerting**: Less aggressive alerting thresholds

#### Production Environment
- **Resource Scaling**: Full resource allocation
- **Data Retention**: Longer retention periods
- **Instance Types**: Production-grade for optimal performance
- **Alerting**: Strict alerting thresholds

### Example: Environment-Specific Variables

```hcl
# Development (environments/dev/terraform.tfvars)
kinesis_shard_count = 2
kinesis_retention_period = 24
instance_type = "t3.medium"
alert_threshold_cpu = 80

# Production (environments/prod/terraform.tfvars)
kinesis_shard_count = 10
kinesis_retention_period = 168  # 7 days
instance_type = "m5.large"
alert_threshold_cpu = 70
```

## Deployment Workflow

### CI/CD Pipeline

Our project uses GitHub Actions workflows to automate deployments to both environments:

#### Development Deployment
1. Developer pushes code to `dev` branch
2. GitHub Actions workflow for dev environment is triggered
3. Security checks and validation run with dev thresholds
4. On success, changes are automatically deployed to dev environment
5. Developer receives notification of successful deployment

#### Production Deployment
1. Pull request is created from `dev` to `main` branch
2. Code review is performed by team members
3. After approval, PR is merged to `main`
4. GitHub Actions workflow for production is triggered
5. Security checks and validation run with strict thresholds
6. Manual approval is required before applying changes
7. On approval, changes are deployed to production
8. Team receives notification of successful deployment

### Manual Deployment Instructions

#### For Development Environment
```bash
# Initialize Terraform with dev backend
terraform init -backend-config=environments/dev/backend.tf

# Plan the deployment with dev variables
terraform plan -var-file=environments/dev/terraform.tfvars -out=dev.plan

# Apply the plan
terraform apply dev.plan
```

#### For Production Environment
```bash
# Initialize Terraform with prod backend
terraform init -backend-config=environments/prod/backend.tf

# Plan the deployment with prod variables
terraform plan -var-file=environments/prod/terraform.tfvars -out=prod.plan

# Apply the plan (after proper review)
terraform apply prod.plan
```

## Best Practices

### Working with Multiple Environments

1. **Always develop in dev first**: Never make changes directly to production
2. **Keep environments as similar as possible**: Minimize differences to only what's necessary
3. **Document all environment differences**: Make it clear what differs between environments
4. **Use version control for all changes**: Track all infrastructure changes in Git
5. **Regular sync between environments**: Keep dev updated with production changes

### Testing and Validation

1. **Test extensively in dev**: Validate all changes in dev before promoting to production
2. **Use automated testing**: Implement automated tests for infrastructure changes
3. **Perform security scanning**: Run security checks against both environments
4. **Review terraform plans**: Always review the Terraform plan before applying

### State Management

1. **Separate state files**: Keep environment states completely separate
2. **Regular state backups**: Backup Terraform state regularly
3. **Lock state during operations**: Use state locking to prevent concurrent modifications
4. **Use remote state**: Store state in a secure, remote backend

## Troubleshooting

### Common Issues

#### Environment Drift
**Symptom**: Environments become inconsistent over time
**Solution**: Regular sync between environments, infrastructure as code compliance checks, and drift detection

#### Access Control Issues
**Symptom**: Permissions errors when deploying to an environment
**Solution**: Verify that CI/CD service accounts have appropriate permissions for each environment

#### State Lock Issues
**Symptom**: "Error acquiring state lock" messages
**Solution**: Check for abandoned locks and clear them if necessary using `terraform force-unlock`

#### Resource Scaling Problems
**Symptom**: Resources that work in dev fail in prod due to scale
**Solution**: Load testing in dev with production-like data volumes before promotion

### Getting Help

If you encounter issues with the environment setup:

1. Check the CI/CD pipeline logs for detailed error messages
2. Review the Terraform documentation for the affected resources
3. Consult the team's infrastructure lead
4. Reference AWS Kinesis best practices for environment-specific recommendations

## Conclusion

This environment methodology enables our team to develop and test changes safely while maintaining a high-quality production environment. By following these guidelines, we ensure consistent, reliable infrastructure deployments across environments.
