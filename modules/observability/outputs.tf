output "efs_file_system_id" {
  description = "ID of the EFS file system for observability"
  value       = aws_efs_file_system.observability.id
}

output "efs_security_group_id" {
  description = "ID of the EFS security group"
  value       = aws_security_group.efs.id
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.eks_observability.name
}