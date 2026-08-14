# Data lookup for VPC
data "aws_vpc" "lab-vpc" {
  filter {
    name   = "tag:Name"
    values = [var.project-name]
  }
}

# Data lookup for a public subnet (using -2a for single instance)
data "aws_subnet" "lab-subnet-private" {
  filter {
    name   = "tag:Name"
    values = ["${var.project-name}-private"]
  }
}

# Security Group for the AmazonMQ broker
resource "aws_security_group" "mq-broker-sg" {
  name        = "${var.project-name}-mq-broker-sg"
  description = "Security group for the AmazonMQ broker"
  vpc_id      = data.aws_vpc.lab-vpc.id

  tags = {
    Name = "${var.project-name}-mq-broker-sg"
  }
}

# Ingress rule for encrypted OpenWire (ActiveMQ default port) from within the VPC
resource "aws_vpc_security_group_ingress_rule" "allow-openwire-encrypted" {
  description       = "Allow inbound encrypted OpenWire traffic to AmazonMQ from within the VPC"
  security_group_id = aws_security_group.mq-broker-sg.id
  cidr_ipv4         = data.aws_vpc.lab-vpc.cidr_block
  from_port         = 61617
  ip_protocol       = "tcp"
  to_port           = 61617
}

# Ingress rule for ActiveMQ Web Console from within the VPC
resource "aws_vpc_security_group_ingress_rule" "allow-web-console" {
  description       = "Allow inbound ActiveMQ Web Console traffic to AmazonMQ from within the VPC"
  security_group_id = aws_security_group.mq-broker-sg.id
  cidr_ipv4         = data.aws_vpc.lab-vpc.cidr_block
  from_port         = 8162
  ip_protocol       = "tcp"
  to_port           = 8162
}

# Egress rule to allow all outbound traffic from the broker
resource "aws_vpc_security_group_egress_rule" "allow-all-outbound" {
  description       = "Allow all outbound traffic from AmazonMQ broker"
  security_group_id = aws_security_group.mq-broker-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Generate a random username for the MQ broker
resource "random_string" "mq_username_suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}

# Generate a random password for the MQ broker
resource "random_password" "mq_password" {
  length           = 20
  special          = true
  override_special = "!@#$%^&*"
}

# AmazonMQ Broker resource
resource "aws_mq_broker" "activemq_broker" {
  broker_name                = "${var.project-name}-mq-broker"
  region                     = "us-east-2"
  engine_type                = "ActiveMQ"
  engine_version             = "5.19"
  auto_minor_version_upgrade = true
  host_instance_type         = "mq.t3.micro"
  deployment_mode            = "SINGLE_INSTANCE"

  subnet_ids      = [data.aws_subnet.lab-subnet-private.id]
  security_groups = [aws_security_group.mq-broker-sg.id]

  user {
    username = "mq-user-${random_string.mq_username_suffix.result}"
    password = random_password.mq_password.result
  }

  logs {
    general = false # Broker logging explicitly disabled as requested
  }

  tags = {
    Name        = "${var.project-name}-mq-broker"
    Environment = "codebeneath-lab"
    ManagedBy   = "terraform"
  }
}
