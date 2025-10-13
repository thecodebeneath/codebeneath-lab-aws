resource "aws_msk_vpc_connection" "msk-multivpc-private-connectivity" {
  authentication     = "SASL_SCRAM"
  target_cluster_arn = var.msk-target-cluster-arn
  vpc_id             = aws_vpc.mgmt-tf.id
  client_subnets     = [aws_subnet.mgmt-tf-public-2a.id, aws_subnet.mgmt-tf-public-2b.id]
  security_groups    = [aws_security_group.msk-managed-connection-sg.id]
}

resource "aws_security_group" "msk-managed-connection-sg" {
  name        = "${var.project-name}-msk-managed-connection-sg"
  description = "Security group and rules for this account to use a MSK managed connection to another account"
  vpc_id      = data.aws_vpc.mgmt-tf.id

  tags = {
    Name = "${var.project-name}-msk-managed-connection-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_14001_14100" {
  description = "Allow inbound tcp traffic to the msk managed connection (PrivateLink standard port range)"
  security_group_id = aws_security_group.msk-managed-connection-sg.id
  cidr_ipv4         = "${aws_instance.bootstrap-ec2.private_ip}/32"
  ip_protocol       = "tcp"
  from_port         = 14001
  to_port           = 14100
}
