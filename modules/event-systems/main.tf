# Kinesis Data Stream
resource "aws_kinesis_stream" "main" {
  name             = "${var.project_name}-stream"
  shard_count      = 1
  retention_period = 24

  shard_level_metrics = [
    "IncomingRecords",
    "OutgoingRecords",
  ]

  tags = {
    Name = "${var.project_name}-kinesis-stream"
  }
}

# Kinesis Firehose Delivery Stream
resource "aws_kinesis_firehose_delivery_stream" "main" {
  name        = "${var.project_name}-firehose"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.firehose_bucket.arn
    prefix     = "year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"

    buffering_size     = 5
    buffering_interval = 300

    compression_format = "GZIP"
  }
}

# S3 Bucket for Firehose
resource "aws_s3_bucket" "firehose_bucket" {
  bucket = "${var.project_name}-firehose-${random_string.bucket_suffix.result}"
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# IAM Role for Firehose
resource "aws_iam_role" "firehose_role" {
  name = "${var.project_name}-firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "firehose_policy" {
  name = "${var.project_name}-firehose-policy"
  role = aws_iam_role.firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.firehose_bucket.arn,
          "${aws_s3_bucket.firehose_bucket.arn}/*"
        ]
      }
    ]
  })
}

# EventBridge Custom Bus
resource "aws_cloudwatch_event_bus" "main" {
  name = "${var.project_name}-event-bus"
}

# EventBridge Rule
resource "aws_cloudwatch_event_rule" "main" {
  name           = "${var.project_name}-rule"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["myapp"]
    detail-type = ["User Action"]
  })
}

# SQS Queue
resource "aws_sqs_queue" "main" {
  name                      = "${var.project_name}-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 4
  })
}

# Dead Letter Queue
resource "aws_sqs_queue" "dlq" {
  name = "${var.project_name}-dlq"
}

# SNS Topic
resource "aws_sns_topic" "main" {
  name = "${var.project_name}-topic"
}

# SNS Subscription to SQS
resource "aws_sns_topic_subscription" "sqs" {
  topic_arn = aws_sns_topic.main.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.main.arn
}

# EventBridge Target (SQS)
resource "aws_cloudwatch_event_target" "sqs" {
  rule           = aws_cloudwatch_event_rule.main.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  target_id      = "SendToSQS"
  arn            = aws_sqs_queue.main.arn
}

# SQS Queue Policy for EventBridge
resource "aws_sqs_queue_policy" "main" {
  queue_url = aws_sqs_queue.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.main.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.main.arn
          }
        }
      }
    ]
  })
}

# Kinesis Data Analytics Application
resource "aws_kinesis_analytics_application" "main" {
  name = "${var.project_name}-analytics"

  application_code = <<EOF
CREATE OR REPLACE STREAM "DESTINATION_SQL_STREAM" (
  ticker_symbol VARCHAR(4),
  change DOUBLE,
  price DOUBLE
);

CREATE OR REPLACE PUMP "STREAM_PUMP" AS INSERT INTO "DESTINATION_SQL_STREAM"
SELECT STREAM ticker_symbol, change, price
FROM "SOURCE_SQL_STREAM_001"
WHERE change > 1.0;
EOF

  inputs {
    name_prefix = "SOURCE_SQL_STREAM"
    
    kinesis_stream {
      resource_arn = aws_kinesis_stream.main.arn
      role_arn     = aws_iam_role.analytics_role.arn
    }

    schema {
      record_columns {
        name     = "ticker_symbol"
        sql_type = "VARCHAR(4)"
        mapping  = "ticker_symbol"
      }
      
      record_columns {
        name     = "change"
        sql_type = "DOUBLE"
        mapping  = "change"
      }
      
      record_columns {
        name     = "price"
        sql_type = "DOUBLE"
        mapping  = "price"
      }

      record_format {
        record_format_type = "JSON"
        
        mapping_parameters {
          json {
            record_row_path = "$"
          }
        }
      }
    }
  }

  outputs {
    name = "DESTINATION_SQL_STREAM"
    
    kinesis_stream {
      resource_arn = aws_kinesis_stream.output.arn
      role_arn     = aws_iam_role.analytics_role.arn
    }

    schema {
      record_format_type = "JSON"
    }
  }
}

# Output Kinesis Stream for Analytics
resource "aws_kinesis_stream" "output" {
  name             = "${var.project_name}-output-stream"
  shard_count      = 1
  retention_period = 24

  tags = {
    Name = "${var.project_name}-output-stream"
  }
}

# IAM Role for Kinesis Analytics
resource "aws_iam_role" "analytics_role" {
  name = "${var.project_name}-analytics-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "kinesisanalytics.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "analytics_policy" {
  name = "${var.project_name}-analytics-policy"
  role = aws_iam_role.analytics_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kinesis:DescribeStream",
          "kinesis:GetShardIterator",
          "kinesis:GetRecords",
          "kinesis:PutRecord",
          "kinesis:PutRecords"
        ]
        Resource = [
          aws_kinesis_stream.main.arn,
          aws_kinesis_stream.output.arn
        ]
      }
    ]
  })
}