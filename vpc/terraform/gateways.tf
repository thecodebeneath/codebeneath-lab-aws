resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lab.id
  tags = {
    Name = var.project-name
  }
}

# resource "aws_eip" "nat" {
#   domain = "vpc"
#   tags = {
#     Name = var.project-name
#   }
# }

# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.lab-public-2a.id
#   tags = {
#     Name = var.project-name
#   }
#   depends_on = [aws_internet_gateway.igw]
# }

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

# resource "aws_route_table" "private-exteral" {
#   vpc_id = aws_vpc.lab.id
#   route {
#     cidr_block                 = "0.0.0.0/0"
#     nat_gateway_id             = aws_nat_gateway.nat.id
#   }
#   tags = {
#     Name = "${var.project-name}-private"
#   }
# }

resource "aws_route_table_association" "public-2a" {
  subnet_id      = aws_subnet.lab-public-2a.id
  route_table_id = aws_route_table.public-igw.id
}

resource "aws_route_table_association" "public-2b" {
  subnet_id      = aws_subnet.lab-public-2b.id
  route_table_id = aws_route_table.public-igw.id
}

# resource "aws_route_table_association" "private" {
#   subnet_id      = aws_subnet.private.id
#   route_table_id = aws_route_table.private-exteral.id
# }

resource "aws_vpc_endpoint" "s3-gw" {
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
			"Principal": "*",
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

# resource "aws_security_group" "ecr-sg" {
#   name        = "${var.project-name}-ecr-sg"
#   description = "Allow access to ECR"
#   vpc_id     = aws_vpc.lab.id
#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.0.0/16"]  # Adjust as necessary
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"  # All traffic
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "${var.project-name}-ecr-sg"
#   }
# }

# resource "aws_vpc_endpoint" "ecr-dkr-endpoint" {
#   vpc_endpoint_type   = "Interface"
#   service_name        = "com.amazonaws.us-east-2.ecr.dkr"
#   vpc_id              = aws_vpc.main.id
#   private_dns_enabled = true
#   security_group_ids  = [ aws_security_group.ecr-sg.id ]
#   subnet_ids          = [ aws_subnet.lab-public-2a.id ]
#   tags = {
#     Name = "${var.project-name}-s3-endpoint"
#   }
# }

# resource "aws_vpc_endpoint" "ecr-api-endpoint" {
#   vpc_endpoint_type   = "Interface"
#   service_name        = "com.amazonaws.us-east-2.ecr.api"
#   vpc_id              = aws_vpc.main.id
#   private_dns_enabled = true
#   security_group_ids  = [ aws_security_group.ecr-sg.id ]
#   subnet_ids          = [ aws_subnet.lab-public-2a.id ]
#   tags = {
#     Name = "${var.project-name}-s3-endpoint"
#   }
# }
