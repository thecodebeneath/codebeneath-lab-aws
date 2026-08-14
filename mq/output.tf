output "mq_broker_id" {
  description = "The ID of the AmazonMQ broker"
  value       = aws_mq_broker.activemq_broker.id
}

output "mq_broker_arn" {
  description = "The ARN of the AmazonMQ broker"
  value       = aws_mq_broker.activemq_broker.arn
}

output "mq_broker_endpoints" {
  description = "The list of endpoints for the AmazonMQ broker"
  value       = aws_mq_broker.activemq_broker.instances[*].endpoints
}

output "mq_broker_username" {
  description = "The username for the AmazonMQ broker"
  value       = "mq-user-${random_string.mq_username_suffix.result}"
  sensitive   = true
}

output "mq_broker_password" {
  description = "The password for the AmazonMQ broker"
  value       = random_password.mq_password.result
  sensitive   = true
}

output "mq_vpc_endpoint_id" {
  description = "The ID of the Amazon MQ VPC endpoint"
  value       = aws_vpc_endpoint.mq.id
}

output "lambda_reboot_function_arn" {
  description = "The ARN of the Amazon MQ reboot Lambda function"
  value       = aws_lambda_function.reboot_broker.arn
}

output "lambda_reboot_function_name" {
  description = "The name of the Amazon MQ reboot Lambda function"
  value       = aws_lambda_function.reboot_broker.function_name
}

