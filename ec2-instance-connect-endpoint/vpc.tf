# data "aws_caller_identity" "current" {}

# This default SG will be associated to VPCs, but unused - make it deny/deny for security compliance
resource "aws_default_security_group" "eice-default-sg" {
  vpc_id = aws_vpc.eice-vpc.id
  tags = {
    Name = "${var.project-name}-eice-default-sg"
  }
}

resource "aws_vpc" "eice-vpc" {
  #checkov:skip=CKV2_AWS_11:AWS VPC Flow Logs not enabled
  cidr_block = var.vpc-cidr-block
  enable_dns_hostnames = false
  enable_dns_support = false
  tags = {
    Name = "${var.project-name}-eice"
  }
}

resource "aws_subnet" "eice-private" {
  vpc_id            = aws_vpc.eice-vpc.id
  cidr_block        = var.private-subnet-cidr-block
  availability_zone = "us-east-2a"
  tags = {
    Name = "${var.project-name}-eice-private"
  }
}
