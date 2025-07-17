data "aws_subnet" "bootstrap-target" {
  id = var.public-subnet-id
}

data "aws_ami" "al2023" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "bootstrap" {
  ami               = var.bootstap-ami != "" ? var.bootstap-ami : data.aws_ami.al2023.id
  instance_type     = var.bootstrap-instance-type
  subnet_id         = var.public-subnet-id
  key_name          = var.bootstrap-key-name
  availability_zone = "us-east-2a"
  vpc_security_group_ids   = [aws_security_group.allow.id]
  associate_public_ip_address = true
  root_block_device {
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
  availability_zone = data.aws_subnet.bootstrap-target.availability_zone
  size = 100
  tags = {
    Name = "${var.project-name}-bootstrap-data"
  }
}

resource "aws_volume_attachment" "datavol" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.datavol.id 
  instance_id = aws_instance.bootstrap.id
}

resource "aws_security_group" "allow" {
  name        = "${var.project-name}-allow_ssh"
  description = "Allow ssh inbound traffic and all outbound traffic"
  vpc_id      = var.lab-vpc-id

  tags = {
    Name = "${var.project-name}-allow_ssh"
  }
}

# resource "aws_vpc_security_group_ingress_rule" "allow_http_80" {
#   security_group_id = aws_security_group.allow.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 80
#   ip_protocol       = "tcp"
#   to_port           = 80
# }

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_22" {
  security_group_id = aws_security_group.allow.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}