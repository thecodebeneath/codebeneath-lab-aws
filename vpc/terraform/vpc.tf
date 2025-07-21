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

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lab.id
  tags = {
    Name = var.project-name
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = var.project-name
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = var.project-name
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public-igw" {
  vpc_id = aws_vpc.lab.id
  route {
    cidr_block                 = "0.0.0.0/0"
    gateway_id                 = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.project-name}-public"
  }
}

resource "aws_route_table" "private-exteral" {
  vpc_id = aws_vpc.lab.id
  route {
    cidr_block                 = "0.0.0.0/0"
    nat_gateway_id             = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "${var.project-name}-private"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public-igw.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private-exteral.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_endpoint_type = "Gateway"
  service_name = "com.amazonaws.us-east-2.s3"
  vpc_id       = aws_vpc.lab.id
  # this will manage a route table entry for prefix list (pl-...s3) -> endpoint (vpce-...) 
  route_table_ids   = [aws_route_table.public-igw.id]
  policy = <<POLICY
{
	"Version": "2008-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"AWS": "${data.aws_caller_identity.current.arn}"
			},
			"Action": "s3:*",
			"Resource": "*"
		}
	]
}
POLICY
  tags = {
    Name = "${var.project-name}-s3-endpoint"
  }
}
