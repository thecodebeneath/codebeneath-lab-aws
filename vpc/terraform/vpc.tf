data "aws_caller_identity" "current" {}

resource "aws_vpc" "lab" {
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

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = var.public-subnet-cidr-block
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project-name}-public"
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
