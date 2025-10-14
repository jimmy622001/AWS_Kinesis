# AWS Learning Environment with Terraform

This Terraform configuration creates a comprehensive AWS learning environment covering all major AWS services and architectural patterns.

## Architecture Overview

### 1. Cloud Infrastructure Implementation
- **VPC with Multi-AZ Setup**: Public/private subnets across 2 AZs
- **NAT Gateways**: For private subnet internet access
- **VPC Endpoints**: S3 and DynamoDB for private connectivity
- **Load Balancers**: Application Load Balancer with auto-scaling

### 2. Event-Based Systems
- **Kinesis Data Streams**: Real-time data streaming
- **Kinesis Firehose**: Data delivery to S3
- **EventBridge**: Custom event bus with rules
- **SQS/SNS**: Pub/sub messaging with Dead Letter Queues

### 3. Networking and Security
- **Security Groups**: Web, ECS, ALB, and Lambda security groups
- **KMS**: Encryption key management
- **IAM Roles**: Least-privilege access for all services
- **VPC Flow Logs**: Network traffic monitoring

### 4. Automation and Operational Excellence
- **CI/CD Pipeline**: CodePipeline, CodeBuild, CodeCommit
- **CloudWatch**: Dashboards, alarms, and monitoring
- **CloudTrail**: API call logging
- **Infrastructure as Code**: Modular Terraform design

### 5. Serverless Architecture
- **Lambda Functions**: With VPC connectivity
- **API Gateway**: RESTful API endpoints
- **DynamoDB**: NoSQL database
- **S3**: Object storage with versioning

### 6. Container Orchestration
- **ECS Fargate**: Serverless containers
- **Auto Scaling**: CPU-based scaling policies
- **Application Load Balancer**: Traffic distribution

## Deployment Instructions

### Prerequisites
1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.0 installed
3. Sufficient AWS permissions for resource creation

### Step 1: Initialize Terraform
```bash
terraform init
```

### Step 2: Configure Variables
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your preferred settings
```

### Step 3: Plan Deployment
```bash
terraform plan
```

### Step 4: Deploy Infrastructure
```bash
terraform apply
```

### Step 5: Verify Deployment
Check the outputs for important resource information:
- VPC ID and subnet IDs
- Lambda function name
- ECS cluster name
- Load balancer DNS name
- API Gateway URL

## Learning Exercises

### 1. Networking
- Explore VPC configuration and routing tables
- Test connectivity between public and private subnets
- Examine NAT Gateway traffic patterns

### 2. Serverless
- Invoke Lambda function via API Gateway
- Test DynamoDB operations through Lambda
- Monitor function performance in CloudWatch

### 3. Containers
- Deploy custom container images to ECS
- Test auto-scaling by generating load
- Examine load balancer health checks

### 4. Event Systems
- Send events to EventBridge custom bus
- Publish messages to SNS topics
- Process messages from SQS queues
- Stream data through Kinesis

### 5. Monitoring
- Create custom CloudWatch dashboards
- Set up additional alarms
- Analyze VPC Flow Logs
- Review CloudTrail events

### 6. CI/CD
- Push code to CodeCommit repository
- Trigger pipeline builds
- Implement blue/green deployments

## Cost Management
- Monitor costs using AWS Cost Explorer
- Set up billing alerts
- Use AWS Trusted Advisor recommendations
- Clean up resources when not needed:
  ```bash
  terraform destroy
  ```

## Security Best Practices Implemented
- Least-privilege IAM roles
- Encrypted storage (S3, EBS)
- VPC security groups with minimal access
- Private subnets for backend services
- KMS key management
- CloudTrail logging enabled

## Troubleshooting
- Check CloudWatch logs for application issues
- Use VPC Flow Logs for network troubleshooting
- Review CloudTrail for API call history
- Monitor resource limits and quotas

## Next Steps
1. Implement AWS WAF for web application protection
2. Add AWS Config for compliance monitoring
3. Set up AWS Systems Manager for patch management
4. Implement disaster recovery with cross-region replication
5. Add AWS X-Ray for distributed tracing