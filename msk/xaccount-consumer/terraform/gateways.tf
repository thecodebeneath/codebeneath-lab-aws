resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mgmt-tf.id
  tags = {
    Name = var.project-name
  }
}

resource "aws_route_table" "public-igw" {
  vpc_id = aws_vpc.mgmt-tf.id
  route {
    cidr_block                 = "0.0.0.0/0"
    gateway_id                 = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.project-name}-public"
  }
}

resource "aws_route_table_association" "public-2a" {
  subnet_id      = aws_subnet.mgmt-tf-public-2a.id
  route_table_id = aws_route_table.public-igw.id
}

resource "aws_route_table_association" "public-2b" {
  subnet_id      = aws_subnet.mgmt-tf-public-2b.id
  route_table_id = aws_route_table.public-igw.id
}
