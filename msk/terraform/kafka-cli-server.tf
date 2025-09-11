data "aws_subnet" "kafka-client-subnet" {
    filter {
      name   = "tag:Name"
      values = ["${var.project-name}-public-2a"]
    }
}

data "aws_ami" "al2023" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

data "http" "workstation-ip" {
  url = "https://ifconfig.me/ip"
}

locals {
  workstation-ip = data.http.workstation-ip.response_body
}

resource "aws_instance" "kafka-client-ec2" {
  #checkov:skip=CKV_AWS_126:Ensure that detailed monitoring is enabled for EC2 instances
  #checkov:skip=CKV_AWS_135:Ensure that EC2 is EBS optimized
  ami                      = var.kafka-client-ami != "" ? var.kafka-client-ami : data.aws_ami.al2023.id
  instance_type            = var.kafka-client-instance-type
  subnet_id                = data.aws_subnet.kafka-client-subnet.id
  key_name                 = var.kafka-key-name
  iam_instance_profile     = aws_iam_instance_profile.kafka-client-ec2.name
  availability_zone        = "us-east-2a"
  vpc_security_group_ids   = [aws_security_group.kafka-client-sg.id]
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  root_block_device {
    volume_type = "gp3"
    volume_size = 10
    #checkov:skip=CKV_AWS_189:Ensure EBS Volume is encrypted by KMS using a customer managed key
    encrypted = true
    tags = {
      Name = "${var.project-name}-kafka-client-root"
    }
  }
  lifecycle {
    ignore_changes = [ ami ]
  }
  tags = {
    Name = "${var.project-name}-kafka-client"
  }
}

resource "aws_eip" "kafka-client-eip" {
  instance = aws_instance.kafka-client-ec2.id
  domain   = "vpc"
}

resource "aws_security_group" "kafka-client-sg" {
  name        = "${var.project-name}-kafka-client-sg"
  description = "Security group and rules for the Lab VPC kafka client ec2"
  vpc_id      = data.aws_vpc.lab-vpc.id

  tags = {
    Name = "${var.project-name}-kafka-client-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "dev-allow-ssh-22" {
  #checkov:skip=CKV_AWS_24:Ensure no security groups allow ingress from 0.0.0.0:0 to port 22
  description = "Allow inbound ssh traffic to the Lab VPC kafka client ec2"
  security_group_id = aws_security_group.kafka-client-sg.id
  cidr_ipv4         = "${local.workstation-ip}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow-all-traffic-ipv4" {
  description = "Allow all outbound traffic from Lab VPC kafka client ec2"
  security_group_id = aws_security_group.kafka-client-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
