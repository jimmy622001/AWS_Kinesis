# AWS Trading Infrastructure with Terraform

Production-ready trading infrastructure with ultra-low latency architecture, regulatory compliance, and enterprise-grade security.

## Architecture Overview

### Core Components

**Networking & Security**
- Multi-AZ VPC with public/private subnets
- Enhanced networking (SR-IOV, ENA) for low latency
- VPC endpoints for private connectivity
- Transit Gateway and IPSec VPN
- AWS WAF, Security Groups, KMS encryption
- AWS Secrets Manager for credential management

**Event Processing**
- Kinesis Data Streams (10 shards, 10K+ msg/sec)
- EventBridge for order routing
- SQS/SNS with dead letter queues
- Lambda functions with X-Ray tracing

**Container Orchestration**
- EKS cluster with managed node groups and auto-scaling
- Cluster Autoscaler for automatic node scaling
- EKS addons (VPC CNI, CoreDNS, Kube-proxy)
- OIDC provider for service account integration

**Data & Storage**
- RDS Multi-AZ for high availability
- DynamoDB for real-time data
- S3 with versioning and encryption
- EFS for persistent storage

**Monitoring & CI/CD**
- Prometheus and Grafana dashboards
- CloudWatch with custom metrics
- CodePipeline, CodeBuild, CodeCommit
- AWS Backup with automated snapshots

## Deployment Instructions

### Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- Appropriate AWS permissions

### Step 1: Initialize Terraform

```bash
terraform init
```

### Step 2: Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit with your environment settings
```

### Step 3: Plan Deployment

```bash
terraform plan
```

### Step 4: Deploy Infrastructure

```bash
terraform apply
```

### Step 5: Access EKS Cluster

```bash
# Configure kubectl
aws eks update-kubeconfig --region <your-region> --name <project-name>-eks

# Verify cluster access
kubectl get nodes
kubectl get pods --all-namespaces
```

## Key Features

- **Ultra-Low Latency**: Sub-millisecond networking with enhanced instances
- **High Availability**: Multi-AZ deployment with automated failover
- **Disaster Recovery**: Cross-region pilot light DR with automated failover capabilities
- **Security**: KMS encryption, VPC isolation, OIDC integration
- **Monitoring**: CloudWatch logs with comprehensive cluster logging
- **Auto-Scaling**: Cluster Autoscaler with dynamic node scaling (1-10 nodes)
- **Compliance**: Audit trails and regulatory reporting

## Disaster Recovery Configuration

The project implements a cross-region disaster recovery strategy using a pilot light approach with automatic scaling:

- **Pilot Light Architecture**: Minimal infrastructure (1 t3.small node) maintained in the DR region
- **Automatic Scaling on Failover**: DR environment automatically scales to match primary region's configuration
- **Automatic Scale Down**: Returns to pilot light mode when failing back to primary
- **Cross-Region Replication**: Automated data replication between primary and DR regions
- **Automated Failover**: Route 53 health checks and Lambda functions for automated failover
- **Recovery Objectives**: 
  - RTO: 5-15 minutes (automated scaling)
  - RPO: ~15 minutes (data replication lag)
- **Data Replication**: RDS read replicas, S3 CRR, DynamoDB global tables
- **Automated Testing**: Regular DR drills using automated testing scripts

### How Automatic Scaling Works

1. **Failover Detection**:
   - Route 53 health checks detect primary region failure
   - EventBridge triggers the scaling Lambda function
   - Lambda scales up the DR environment to match primary's configuration

2. **Scaling Process**:
   - Retrieves primary EKS node group configuration
   - Updates DR node group to match:
     - Instance types
     - Desired/min/max node counts
     - Other scaling parameters

3. **Failback Process**:
   - When primary region recovers
   - EventBridge detects health restoration
   - Lambda scales down DR to pilot light mode (1 t3.small node)

4. **Monitoring & Alerts**:
   - CloudWatch metrics track scaling events
   - SNS notifications for all state changes
   - Logs all scaling operations for audit

### Manual Testing

```bash
# Test failover (scale up)
aws lambda invoke \
  --function-name ${var.project_name}-sync-cluster-sizes \
  --payload '{"action": "failover"}' \
  response.json

# Test failback (scale down)
aws lambda invoke \
  --function-name ${var.project_name}-sync-cluster-sizes \
  --payload '{"action": "failback"}' \
  response.json
```

See the [Multi-Region DR Strategy](docs/disaster-recovery/multi-region-dr-strategy.md) document for detailed implementation.

## EKS Auto-Scaling Configuration

The EKS cluster is configured with automatic scaling capabilities:

### Cluster Autoscaler
- Automatically scales worker nodes based on pod resource requirements
- Scales from 1 to 10 nodes based on demand
- Uses OIDC provider for secure service account authentication

### Node Group Configuration
- **Instance Type**: t3.medium
- **Capacity Type**: On-Demand
- **Min Size**: 1 node
- **Max Size**: 10 nodes
- **Desired Size**: 2 nodes

### EKS Addons
- **VPC CNI**: Advanced networking for pods
- **CoreDNS**: DNS resolution within the cluster
- **Kube-proxy**: Network proxy for Kubernetes services

```bash
# Deploy Cluster Autoscaler
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

# Annotate the deployment
kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"

# Edit deployment to add cluster name
kubectl -n kube-system edit deployment.apps/cluster-autoscaler
```

## Cleanup

```bash
terraform destroy
```

## Security Scanning Tools

This project includes multiple security scanning tools to ensure infrastructure code quality and security:

### Implemented Tools

- **Checkov**: Scans for cloud misconfigurations and security issues
- **TFLint**: Validates Terraform code quality and AWS best practices
- **KICS**: Finds security vulnerabilities and compliance issues
- **Terrascan**: Policy-as-code security scanner
- **CloudFormation Guard**: Policy-as-code validation with custom rules

### Using the Security Tools

```bash
# Run security scans locally
./scripts/security-scan.sh

# Run CloudFormation Guard validation
.\guard-validate.ps1

# Set up pre-commit hooks
   pre-commit install

### CloudFormation Guard Integration

CloudFormation Guard provides additional policy validation with custom organizational rules:

- **Custom Rules**: Organization-specific security policies in `.cfn-guard/rules.guard`
- **Policy as Code**: Version-controlled security policies
- **Compliance Validation**: Structured validation output for audit trails
- **Pre-deployment Checks**: Catch policy violations before infrastructure deployment

```powershell
# Validate infrastructure against custom policies
.\guard-validate.ps1
```

**Guard Rules Include:**
- S3 bucket public access blocking
- KMS key rotation enforcement
- ECS container security (non-root users)
- ALB security headers validation
- CloudWatch logs encryption requirements

All security scans run automatically in CI/CD pipelines.

## Documentation

Comprehensive documentation is available in the `docs/` folder with detailed guides for each component:

### Architecture
- [Detailed Architecture Components](docs/architecture/detailed-components.md) - Complete infrastructure breakdown
- [Multi-Region DR Strategy](docs/disaster-recovery/multi-region-dr-strategy.md) - Cross-region disaster recovery implementation

### Operations
- [Trading System Exercises](docs/operations/trading-exercises.md) - Learning exercises and advanced implementation paths
- [Troubleshooting Guide](docs/operations/troubleshooting.md) - Common issues and solutions
- [Security Best Practices](docs/operations/security-best-practices.md) - Comprehensive security implementation details

### Deployment
- [Rancher Kubernetes Management](docs/deployment/rancher-management.md) - Complete Kubernetes management guide

### Security
- [Terraform Security Tools Overview](docs/security/terraform-security-tools.md) - Security scanning tools documentation
- [Security Tools Installation Guide](docs/security/installation-guide.md) - Setup instructions for security tools

## Architecture Diagrams

### Infrastructure Overview
![AWS Kinesis Infrastructure Diagram](docs/infrastructure_diagram/aws_kinesis_infrastructure.png)

### System Layout
![Layout Image](docs/images/layout_image.png)
![AWS Kinesis Layout](docs/images/aws_kinesis_layout.png)

For interactive diagrams, see the [infrastructure diagram documentation](docs/infrastructure_diagram/README.md) or open the [draw.io XML file](docs/infrastructure_diagram/aws_kinesis_infrastructure.drawio.xml) in [draw.io](https://app.diagrams.net).
