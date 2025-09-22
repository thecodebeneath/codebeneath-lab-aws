data "aws_vpc" "mgmt-tf" {
    filter {
      name   = "tag:Name"
      values = [var.project-name]
    }
    depends_on = [aws_vpc.mgmt-tf]
}

data "aws_subnet" "bootstrap-subnet" {
    filter {
      name   = "tag:Name"
      values = ["${var.project-name}-public-2a"]
    }
    depends_on = [aws_subnet.mgmt-tf-public-2a]
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

resource "aws_instance" "bootstrap-ec2" {
  #checkov:skip=CKV_AWS_126:Ensure that detailed monitoring is enabled for EC2 instances
  #checkov:skip=CKV_AWS_135:Ensure that EC2 is EBS optimized
  ami                      = var.bootstap-ami != "" ? var.bootstap-ami : data.aws_ami.al2023.id
  instance_type            = var.bootstrap-instance-type
  subnet_id                = data.aws_subnet.bootstrap-subnet.id
  key_name                 = var.bootstrap-key-name
  iam_instance_profile     = aws_iam_instance_profile.bootstrap-ec2.name
  availability_zone        = "us-east-2a"
  vpc_security_group_ids   = [aws_security_group.bootstrap-sg.id]
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
      Name = "${var.project-name}-bootstrap-root"
    }
  }
  lifecycle {
    ignore_changes = [ ami ]
  }
  tags = {
    Name = "${var.project-name}-bootstrap"
  }
}

resource "aws_eip" "bootstrap-eip" {
  instance = aws_instance.bootstrap-ec2.id
  domain   = "vpc"
}

resource "aws_security_group" "bootstrap-sg" {
  name        = "${var.project-name}-bootstrap-sg"
  description = "Security group and rules for the mgmt-tf VPC bootstrap server"
  vpc_id      = data.aws_vpc.mgmt-tf.id

  tags = {
    Name = "${var.project-name}-bootstrap-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_22" {
  #checkov:skip=CKV_AWS_24:Ensure no security groups allow ingress from 0.0.0.0:0 to port 22
  description = "Allow inbound ssh traffic to the mgmt-tf VPC bootstrap server"
  security_group_id = aws_security_group.bootstrap-sg.id
  cidr_ipv4         = "${local.workstation-ip}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  description = "Allow all outbound traffic from mgmt-tf VPC bootstrap server"
  security_group_id = aws_security_group.bootstrap-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
