# data "aws_caller_identity" "current" {}

# This default SG will be associated to VPCs, but unused - make it deny/deny for security compliance
resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.lab.id
}

resource "aws_vpc" "lab" {
  #checkov:skip=CKV2_AWS_11:AWS VPC Flow Logs not enabled
  cidr_block = var.vpc-cidr-block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = var.project-name
  }
}

resource "aws_vpc_dhcp_options" "dns-resolver" {
  domain_name_servers = [ "AmazonProvidedDNS" ]
  tags = {
    Name = var.project-name
  }
}

resource "aws_vpc_dhcp_options_association" "dhcp-lab" {
  vpc_id = aws_vpc.lab.id
  dhcp_options_id = aws_vpc_dhcp_options.dns-resolver.id
}

resource "aws_subnet" "lab-public-2a" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = var.public-subnet-2a-cidr-block
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.project-name}-public-2a"
  }
}

resource "aws_subnet" "lab-public-2b" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = var.public-subnet-2b-cidr-block
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.project-name}-public-2b"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.lab.id
  cidr_block        = var.private-subnet-cidr-block
  availability_zone = "us-east-2a"
  tags = {
    Name = "${var.project-name}-private"
  }
}
