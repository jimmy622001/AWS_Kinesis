output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.main.function_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.main.name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.lambda_bucket.bucket
}

output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = aws_api_gateway_stage.main.invoke_url
}