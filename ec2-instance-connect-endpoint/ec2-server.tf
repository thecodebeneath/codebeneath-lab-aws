data "aws_ami" "al2023" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "eice-ec2" {
  #checkov:skip=CKV_AWS_126:Ensure that detailed monitoring is enabled for EC2 instances
  #checkov:skip=CKV_AWS_135:Ensure that EC2 is EBS optimized
  ami                      = var.eice-ami != "" ? var.eice-ami : data.aws_ami.al2023.id
  instance_type            = var.eice-instance-type
  subnet_id                = aws_subnet.eice-private.id
  availability_zone        = "us-east-2a"
  vpc_security_group_ids   = [aws_security_group.eice-sg.id]
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    #checkov:skip=CKV_AWS_189:Ensure EBS Volume is encrypted by KMS using a customer managed key
    encrypted = true
    tags = {
      Name = "${var.project-name}-eice-root"
    }
  }

  tags = {
    Name = "${var.project-name}-eice"
  }
}

resource "aws_security_group" "eice-ec2-sg" {
  name        = "${var.project-name}-eice-ec2-sg"
  description = "Security group and rules for the eice server"
  vpc_id      = aws_vpc.eice-vpc.id

  tags = {
    Name = "${var.project-name}-eice-ec2-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_22" {
  description       = "Allow inbound ssh traffic to the eice server"
  security_group_id = aws_security_group.eice-ec2-sg.id
  referenced_security_group_id = aws_security_group.eice-sg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  description       = "Allow all outbound traffic from eice server"
  security_group_id = aws_security_group.eice-ec2-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
