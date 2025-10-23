# AWS Trading Platform - Usage Guide

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- kubectl configured for EKS cluster access
- jq for JSON processing (recommended)

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd AWS_Trading_Platform_POC
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit with your environment settings
```

### 4. Deploy Infrastructure

```bash
# Review changes
terraform plan

# Apply changes
terraform apply
```

## Accessing the Cluster

### Configure kubectl

```bash
aws eks update-kubeconfig \
  --region <your-region> \
  --name <project-name>-eks

# Verify access
kubectl get nodes
kubectl get pods --all-namespaces
```

## Disaster Recovery Operations

### Manual Failover Testing

1. **Test Failover (Scale Up DR)**
   ```bash
   aws lambda invoke \
     --function-name ${var.project_name}-sync-cluster-sizes \
     --payload '{"action": "failover"}' \
     response.json
   ```

2. **Test Failback (Scale Down DR)**
   ```bash
   aws lambda invoke \
     --function-name ${var.project_name}-sync-cluster-sizes \
     --payload '{"action": "failback"}' \
     response.json
   ```

### Monitoring DR Events

1. **View Lambda Logs**
   ```bash
   aws logs tail /aws/lambda/${var.project_name}-sync-cluster-sizes --follow
   ```

2. **Check EKS Node Status**
   ```bash
   aws eks describe-nodegroup \
     --cluster-name ${var.project_name}-eks \
     --nodegroup-name ${var.project_name}-dr-nodes \
     --region ${var.dr_region}
   ```

## Maintenance

### Upgrading the Cluster

1. **Update EKS Control Plane**
   ```bash
   terraform apply -target=aws_eks_cluster.dr -var='eks_version=1.28'
   ```

2. **Update Node Groups**
   ```bash
   terraform apply -target=aws_eks_node_group.dr
   ```

### Backup and Restore

1. **Create Manual RDS Snapshot**
   ```bash
   aws rds create-db-snapshot \
     --db-instance-identifier ${var.project_name}-database \
     --db-snapshot-identifier manual-$(date +%Y%m%d-%H%M%S)
   ```

2. **Restore from Snapshot**
   ```bash
   aws rds restore-db-instance-from-db-snapshot \
     --db-instance-identifier ${var.project_name}-restored \
     --db-snapshot-identifier <snapshot-identifier>
   ```

## Troubleshooting

### Common Issues

1. **Permission Errors**
   - Verify IAM roles and policies
   - Check service-linked roles
   - Ensure proper trust relationships

2. **Networking Issues**
   - Verify VPC peering
   - Check security group rules
   - Validate route tables

3. **EKS Node Issues**
   ```bash
   # Check node status
   kubectl get nodes -o wide
   
   # Check node events
   kubectl describe node <node-name>
   
   # Check node logs
   kubectl logs -n kube-system <pod-name>
   ```

## Cleanup

### Destroy Resources

```bash
# Destroy DR resources first
terraform destroy -target=module.disaster_recovery

# Destroy all resources
terraform destroy
```

> **Warning**: This will permanently delete all resources. Ensure you have backups of all important data.

## Support

For additional help, please contact:
- **Email**: support@example.com
- **Slack**: #aws-trading-platform
- **Documentation**: [Internal Wiki](https://wiki.example.com/aws-trading-platform)
