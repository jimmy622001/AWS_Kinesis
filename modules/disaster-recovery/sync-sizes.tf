resource "aws_lambda_function" "sync_sizes" {
  filename      = "${path.module}/sync-sizes.zip"
  function_name = "${var.project_name}-sync-cluster-sizes"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 300

  environment {
    variables = {
      PRIMARY_REGION     = var.aws_region
      DR_REGION          = var.dr_region
      CLUSTER_NAME       = var.project_name
      NODE_GROUP_NAME    = "${var.project_name}-nodes"
      DR_NODE_GROUP_NAME = "${var.project_name}-dr-nodes"
    }
  }
}

data "archive_file" "sync_sizes" {
  type        = "zip"
  output_path = "${path.module}/sync-sizes.zip"

  source {
    content  = <<-EOT
    const AWS = require('aws-sdk');
    
    exports.handler = async (event, context) => {
      console.log('Event:', JSON.stringify(event, null, 2));
      
      const primaryRegion = process.env.PRIMARY_REGION;
      const drRegion = process.env.DR_REGION;
      const clusterName = process.env.CLUSTER_NAME;
      const nodeGroupName = process.env.NODE_GROUP_NAME;
      const drNodeGroupName = process.env.DR_NODE_GROUP_NAME;
      
      // Determine if this is a failover or failback event
      const isFailover = event.action === 'failover' || 
                        event.Records?.[0]?.Sns?.Message?.includes('failover');

      try {
        const primaryEks = new AWS.EKS({ region: primaryRegion });
        const drEks = new AWS.EKS({ region: drRegion });
        
        if (isFailover) {
          console.log('Failover detected, scaling up DR environment');
          
          // Get primary node group config
          let primaryConfig;
          try {
            const primaryNodeGroups = await primaryEks.listNodegroups({ 
              clusterName 
            }).promise();
            
            primaryConfig = await primaryEks.describeNodegroup({
              clusterName,
              nodegroupName: primaryNodeGroups.nodegroups[0]
            }).promise();
            
            console.log('Primary config:', JSON.stringify(primaryConfig, null, 2));
            
            // Update DR node group to match primary
            await drEks.updateNodegroupConfig({
              clusterName,
              nodegroupName: drNodeGroupName,
              scalingConfig: primaryConfig.nodegroup.scalingConfig,
              instanceTypes: primaryConfig.nodegroup.instanceTypes
            }).promise();
            
            console.log('Successfully scaled up DR node group to match primary');
            
          } catch (error) {
            console.error('Error getting primary config, using defaults:', error);
            // Fallback to default scaling if primary is unavailable
            await drEks.updateNodegroupConfig({
              clusterName,
              nodegroupName: drNodeGroupName,
              scalingConfig: {
                minSize: 2,
                maxSize: 10,
                desiredSize: 2
              },
              instanceTypes: ["m5.large"]
            }).promise();
          }
          
        } else {
          console.log('Failback detected, scaling down DR environment to pilot light');
          
          // Scale down to pilot light configuration
          await drEks.updateNodegroupConfig({
            clusterName,
            nodegroupName: drNodeGroupName,
            scalingConfig: {
              minSize: 1,
              maxSize: 10,
              desiredSize: 1
            },
            instanceTypes: ["t3.small"]
          }).promise();
          
          console.log('Successfully scaled down DR node group to pilot light');
        }
        
        return { statusCode: 200, body: 'Success' };
      } catch (error) {
        console.error('Error syncing cluster sizes:', error);
        throw error;
      }
    };
    EOT
    filename = "index.js"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-dr-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_eks" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_eks_access" {
  name        = "${var.project_name}-lambda-eks-access"
  description = "Policy for Lambda to access EKS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:ListNodegroups",
          "eks:DescribeNodegroup",
          "eks:UpdateNodegroupConfig"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_eks_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_eks_access.arn
}

# CloudWatch Log Group for the Lambda function
resource "aws_cloudwatch_log_group" "sync_sizes" {
  name              = "/aws/lambda/${aws_lambda_function.sync_sizes.function_name}"
  retention_in_days = 30
}
