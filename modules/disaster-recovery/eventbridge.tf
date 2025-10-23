# SNS Topic for DR notifications
resource "aws_sns_topic" "dr_alerts" {
  name = "${var.project_name}-dr-alerts"
}

# Allow Lambda to be invoked by SNS
resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sync_sizes.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.dr_alerts.arn
}

# Subscribe Lambda to SNS
resource "aws_sns_topic_subscription" "lambda_failover" {
  topic_arn = aws_sns_topic.dr_alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.sync_sizes.arn
}

# EventBridge rule for failover (scale up)
resource "aws_cloudwatch_event_rule" "failover_initiated" {
  name        = "${var.project_name}-failover-initiated"
  description = "Triggered when DR failover is initiated"

  event_pattern = jsonencode({
    source        = ["aws.health"],
    "detail-type" = ["AWS Health Event"],
    detail = {
      service           = ["ROUTE53"],
      eventTypeCategory = ["issue"],
      statusCode        = ["open"]
    }
  })
}

resource "aws_cloudwatch_event_target" "scale_up_on_failover" {
  rule      = aws_cloudwatch_event_rule.failover_initiated.name
  target_id = "ScaleUpDR"
  arn       = aws_lambda_function.sync_sizes.arn

  input = jsonencode({
    action    = "failover",
    source    = "eventbridge",
    timestamp = "$time"
  })
}

# EventBridge rule for failback (scale down)
resource "aws_cloudwatch_event_rule" "failback_completed" {
  name        = "${var.project_name}-failback-completed"
  description = "Triggered when failback to primary is completed"

  event_pattern = jsonencode({
    source        = ["aws.health"],
    "detail-type" = ["AWS Health Event"],
    detail = {
      service           = ["ROUTE53"],
      eventTypeCategory = ["issue"],
      statusCode        = ["closed"]
    }
  })
}

resource "aws_cloudwatch_event_target" "scale_down_after_failback" {
  rule      = aws_cloudwatch_event_rule.failback_completed.name
  target_id = "ScaleDownDR"
  arn       = aws_lambda_function.sync_sizes.arn

  input = jsonencode({
    action    = "failback",
    source    = "eventbridge",
    timestamp = "$time"
  })
}
