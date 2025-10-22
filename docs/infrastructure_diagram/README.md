# AWS Kinesis Infrastructure Diagram

This directory contains the infrastructure diagram for our AWS Kinesis data processing architecture.

## Quick ASCII Diagram

For terminal-friendly viewing:

```
+-----------------------------------------------------------------------------------------------------------+
|                                               AWS CLOUD                                                    |
| +----------------------------+  +----------------------------+  +----------------------------+             |
| |      DATA INGESTION        |  |    PROCESSING & STORAGE    |  |      EVENT PROCESSING      |             |
| |                            |  |                            |  |                            |             |
| |  +--------------------+    |  |  +--------------------+    |  |  +--------------------+    |             |
| |  |   Kinesis Stream   |    |  |  |  Lambda Function   |    |  |  |  EventBridge Bus   |    |             |
| |  | (10 shards, 7-day) <--------|-------------------->|    |  |  |                    |    |             |
| |  +--------v-----------+    |  |  +--------+------+---+    |  |  +----------+--------+    |             |
| |           |                |  |           |      |        |  |             |             |             |
| |  +--------v-----------+    |  |  +--------v---+ +v-------+|  |  +----------v--------+    |             |
| |  | Kinesis Firehose   |    |  |  |            | |        ||  |  | EventBridge Rule  |    |             |
| |  |                    |    |  |  | DynamoDB   | | API    ||  |  |                   |    |             |
| |  +--------v-----------+    |  |  | Table      | | Gateway||  |  +----+----------+---+    |             |
| |           |                |  |  |            | |        ||  |       |          |        |             |
| |  +--------v-----------+    |  |  +------------+ +--------+|  |  +----v------+  +v-------+|             |
| |  |      S3 Bucket     |    |  |                            |  |  | SQS Queue |  |SNS Topic||             |
| |  |  (Time-partitioned)|    |  |                            |  |  |           |  |        ||             |
| |  +--------------------+    |  |                            |  |  +------^----+  +----^---+|             |
| |                            |  |                            |  |         |            |    |             |
| +----------------------------+  +----------------------------+  +---------+------------+----+             |
|                                                                           |                               |
| +--------------------------------------------------------------------------------------------+            |
| |                               SECURITY & NETWORKING                                         |            |
| | +-------------+   +---------------------+   +--------------------+                          |            |
| | |     VPC     |   |   IAM Roles/Policies |   |   Security Groups  |                          |            |
| | +-------------+   +---------------------+   +--------------------+                          |            |
| +--------------------------------------------------------------------------------------------+            |
+-----------------------------------------------------------------------------------------------------------+

+-----------------------------------------------------------------------------------------------------------+
|                                        EXTERNAL SYSTEMS                                                    |
| +---------------------+                                               +----------------------+            |
| |  Client Applications |                                               |  Monitoring Systems   |            |
| +---------------------+                                               +----------------------+            |
+-----------------------------------------------------------------------------------------------------------+
```

## Viewing the Diagram

### Option 1: Using draw.io (Recommended for editing)

1. Go to [draw.io](https://app.diagrams.net/)
2. Click "Open Existing Diagram"
3. Select "Open from Device"
4. Choose the `aws_kinesis_infrastructure.drawio.xml` file
5. Edit as needed and save changes back to this file

### Option 2: Using GitHub (For viewing only)

- If you're viewing this in GitHub, you can see the static image version directly in the repository at `aws_kinesis_infrastructure.png`

### Option 3: VS Code Extension

1. Install the "Draw.io Integration" extension for VS Code
2. Open the `.drawio.xml` file directly in VS Code

## Infrastructure Components

The diagram shows our complete AWS Kinesis infrastructure with these key components:

1. **Data Ingestion Layer**
   - Kinesis Data Stream (10 shards, 7-day retention)
   - Kinesis Firehose for batch data processing
   - S3 Bucket with time-based partitioning for data storage

2. **Processing & Storage Layer**
   - Lambda function for real-time data processing
   - DynamoDB table for storing processed data
   - API Gateway for REST API access

3. **Event Processing Layer**
   - EventBridge for event routing
   - SQS Queue for reliable message delivery
   - SNS Topic for notifications

4. **Security & Networking**
   - VPC with private subnets
   - IAM roles with least-privilege permissions
   - Security groups for traffic control

## Adding to Git
This diagram is maintained in multiple formats for optimal Git compatibility:
- XML source file (editable in draw.io)
- PNG image (visible directly in Git repos)
- ASCII art (visible in terminals)

To update:
1. Edit the XML file in draw.io
2. Export as PNG
3. Update ASCII art if needed
4. Commit all files together

For detailed guidance on managing diagrams in Git, see our [Git Visualization Guide](git_visualization_guide.md).
