data "aws_region" "current" {}

data "aws_vpc_endpoint_service" "mq" {
  service = "mq"
}

resource "aws_security_group" "mq-endpoint-sg" {
  name        = "${var.project-name}-mq-endpoint-sg"
  description = "Security group for Amazon MQ VPC Interface Endpoint"
  vpc_id      = data.aws_vpc.lab-vpc.id

  tags = {
    Name = "${var.project-name}-mq-endpoint-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "mq_endpoint_ingress_https" {
  description       = "Allow inbound HTTPS traffic to MQ VPC Endpoint from within VPC"
  security_group_id = aws_security_group.mq-endpoint-sg.id
  cidr_ipv4         = data.aws_vpc.lab-vpc.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "mq_endpoint_egress_all" {
  description       = "Allow all outbound traffic from MQ VPC Endpoint"
  security_group_id = aws_security_group.mq-endpoint-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_endpoint" "mq" {
  vpc_id              = data.aws_vpc.lab-vpc.id
  service_name        = data.aws_vpc_endpoint_service.mq.service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [data.aws_subnet.lab-subnet-private.id]
  security_group_ids  = [aws_security_group.mq-endpoint-sg.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project-name}-mq-vpc-endpoint"
  }
}
