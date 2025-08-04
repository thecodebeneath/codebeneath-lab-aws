data "aws_vpc" "lab-vpc" {
    filter {
      name   = "tag:Name"
      values = [var.project-name]
    }
}

data "aws_subnet" "bootstrap-subnet" {
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

resource "aws_instance" "bootstrap-ec2" {
  ami               = var.bootstap-ami != "" ? var.bootstap-ami : data.aws_ami.al2023.id
  instance_type     = var.bootstrap-instance-type
  subnet_id         = data.aws_subnet.bootstrap-subnet.id
  key_name          = var.bootstrap-key-name
  availability_zone = "us-east-2a"
  vpc_security_group_ids   = [aws_security_group.bootstrap-sg.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    tags = {
      Name = "${var.project-name}-bootstrap-root"
    }
  }

  user_data = file("${path.module}/bootstrap-userdata.sh")
  user_data_replace_on_change = false

  lifecycle {
    ignore_changes = [ ami ]
  }
  tags = {
    Name = "${var.project-name}-bootstrap"
  }
}

resource "aws_ebs_volume" "datavol" {
  availability_zone = data.aws_subnet.bootstrap-subnet.availability_zone
  type = "gp3"
  size = 100
  tags = {
    Name = "${var.project-name}-bootstrap-data"
  }
}

resource "aws_volume_attachment" "datavol" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.datavol.id 
  instance_id = aws_instance.bootstrap-ec2.id
}

resource "aws_security_group" "bootstrap-sg" {
  name        = "${var.project-name}-bootstrap-sg"
  description = "Allow ssh inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.lab-vpc.id

  tags = {
    Name = "${var.project-name}-bootstrap-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_22" {
  security_group_id = aws_security_group.bootstrap-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.bootstrap-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}