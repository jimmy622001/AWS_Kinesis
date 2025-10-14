output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.serverless.lambda_function_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.containers.ecs_cluster_name
}

output "kinesis_stream_name" {
  description = "Name of the Kinesis stream"
  value       = module.event_systems.kinesis_stream_name
}

output "eventbridge_bus_name" {
  description = "Name of the EventBridge custom bus"
  value       = module.event_systems.eventbridge_bus_name
}