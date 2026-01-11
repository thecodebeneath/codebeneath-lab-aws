data "http" "workstation-ip" {
  url = "https://ifconfig.me/ip"
}

locals {
  workstation-ip = data.http.workstation-ip.response_body
}

resource "aws_ec2_instance_connect_endpoint" "lab-eice" {
  subnet_id = aws_subnet.eice-private.id
  security_group_ids = [aws_security_group.eice-sg.id]
  preserve_client_ip = false
  tags = {
    Name = "${var.project-name}-eice"
  }
}

resource "aws_security_group" "eice-sg" {
  name        = "${var.project-name}-eice-sg"
  description = "Security group and rules for the eice endpoint"
  vpc_id      = aws_vpc.eice-vpc.id

  tags = {
    Name = "${var.project-name}-eice-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_22_to_eice" {
  description = "Allow inbound ssh traffic to the eice server"
  security_group_id = aws_security_group.eice-sg.id
  cidr_ipv4         = var.private-subnet-cidr-block # preserve_client_ip = false
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_ssh_to_eice_ec2" {
  description       = "Allow ssh outbound traffic from eice endpoint to eice EC2 private IP"
  security_group_id = aws_security_group.eice-sg.id
  cidr_ipv4         = "${aws_instance.eice-ec2.private_ip}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
