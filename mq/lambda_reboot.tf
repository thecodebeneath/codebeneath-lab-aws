# Archive the Python code for Lambda
data "archive_file" "lambda_reboot_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_reboot.py"
  output_path = "${path.module}/lambda_reboot.zip"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_reboot" {
  name        = "${var.project-name}-mq-reboot-lambda-role"
  description = "IAM role for Amazon MQ reboot Lambda function"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project-name}-mq-reboot-lambda-role"
  }
}

# Attach AWS managed VPC access execution role policy (includes CloudWatch Logs and ENI permissions)
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_reboot.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Custom IAM Policy for Amazon MQ actions
resource "aws_iam_role_policy" "lambda_mq_reboot_policy" {
  name = "${var.project-name}-mq-reboot-policy"
  role = aws_iam_role.lambda_reboot.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "mq:ListBrokers"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "mq:RebootBroker",
          "mq:DescribeBroker"
        ]
        Resource = aws_mq_broker.activemq_broker.arn
      }
    ]
  })
}

# Security Group for Lambda Function
resource "aws_security_group" "lambda_reboot_sg" {
  name        = "${var.project-name}-mq-reboot-lambda-sg"
  description = "Security group for Amazon MQ reboot Lambda function"
  vpc_id      = data.aws_vpc.lab-vpc.id

  tags = {
    Name = "${var.project-name}-mq-reboot-lambda-sg"
  }
}

# Egress rule allowing HTTPS to VPC endpoint
resource "aws_vpc_security_group_egress_rule" "lambda_allow_https_outbound" {
  description       = "Allow outbound HTTPS traffic from Lambda to MQ VPC Endpoint"
  security_group_id = aws_security_group.lambda_reboot_sg.id
  cidr_ipv4         = data.aws_vpc.lab-vpc.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# Lambda Function
resource "aws_lambda_function" "reboot_broker" {
  function_name    = "${var.project-name}-mq-reboot"
  description      = "Reboots an Amazon MQ broker by broker name"
  runtime          = "python3.13"
  handler          = "lambda_reboot.lambda_handler"
  role             = aws_iam_role.lambda_reboot.arn
  filename         = data.archive_file.lambda_reboot_zip.output_path
  source_code_hash = data.archive_file.lambda_reboot_zip.output_base64sha256
  timeout          = 60
  memory_size      = 256

  vpc_config {
    subnet_ids         = [data.aws_subnet.lab-subnet-private.id]
    security_group_ids = [aws_security_group.lambda_reboot_sg.id]
  }

  tags = {
    Name = "${var.project-name}-mq-reboot"
  }
}
