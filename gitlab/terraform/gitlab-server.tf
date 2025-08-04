data "aws_vpc" "lab-vpc" {
    filter {
      name   = "tag:Name"
      values = [var.project-name]
    }
}

data "aws_subnet" "lab-subnet-2a" {
    filter {
      name   = "tag:Name"
      values = ["${var.project-name}-public-2a"]
    }
}

data "aws_subnet" "lab-subnet-2b" {
    filter {
      name   = "tag:Name"
      values = ["${var.project-name}-public-2b"]
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

resource "aws_instance" "gitlab-ec2" {
  ami                     = var.gitlab-ami != "" ? var.gitlab-ami : data.aws_ami.al2023.id
  instance_type           = var.gitlab-instance-type
  subnet_id               = data.aws_subnet.lab-subnet-2a.id
  key_name                = var.gitlab-key-name
  iam_instance_profile    = aws_iam_instance_profile.gitlab-ec2.name
  availability_zone       = "us-east-2a"
  vpc_security_group_ids  = [aws_security_group.gitlab-sg.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    tags = {
      Name = "${var.project-name}-gitlab-root"
    }
  }

  user_data = file("${path.module}/gitlab-userdata.sh")
  user_data_replace_on_change = false

  lifecycle {
    ignore_changes = [ ami ]
  }
  tags = {
    Name = "${var.project-name}-gitlab"
  }
}

resource "aws_ebs_volume" "datavol" {
  availability_zone = data.aws_subnet.lab-subnet-2a.availability_zone
  type = "gp3"
  size = 100
  tags = {
    Name = "${var.project-name}-gitlab-data"
  }
}

resource "aws_volume_attachment" "datavol" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.datavol.id 
  instance_id = aws_instance.gitlab-ec2.id
}

resource "aws_security_group" "gitlab-sg" {
  name        = "${var.project-name}-gitlab-sg"
  description = "Allow ssh inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.lab-vpc.id

  tags = {
    Name = "${var.project-name}-gitlab-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_80" {
  security_group_id = aws_security_group.gitlab-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_22" {
  security_group_id = aws_security_group.gitlab-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.gitlab-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
