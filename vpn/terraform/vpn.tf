data "aws_acm_certificate" "server-cert" {
  domain   = var.vpn-server-cert-domain
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "client-cert" {
  domain   = var.vpn-client-cert-domain
  statuses = ["ISSUED"]
}

data "aws_vpc" "lab-vpc" {
    filter {
      name   = "tag:Name"
      values = [var.project-name]
    }
}

data "aws_subnet" "lab-public-subnet" {
    filter {
      name   = "tag:Name"
      values = ["${var.project-name}-public"]
    }
}

resource "aws_ec2_client_vpn_endpoint" "lab-client-vpn" {
  description            = "${var.project-name}-client-vpn-endpoint"
  server_certificate_arn = data.aws_acm_certificate.server-cert.arn
  client_cidr_block      = var.vpn-client-cidr-block
  vpc_id = data.aws_vpc.lab-vpc.id
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = data.aws_acm_certificate.client-cert.arn
  }
  client_login_banner_options {
    enabled = true
    banner_text = "Connected to the Codebeneath Labs VPN."
  }
  connection_log_options {
    enabled = false
  }
  tags = {
    Name = "${var.project-name}-client-vpn-endpoint"
  }
}

# Associate the VPN with the lab VPC
resource "aws_ec2_client_vpn_network_association" "lab-client-vpn-network" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.lab-client-vpn.id
  subnet_id              = data.aws_subnet.lab-public-subnet.id
}

# Grant all users access to the VPC
resource "aws_ec2_client_vpn_authorization_rule" "lab-client-vpn-rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.lab-client-vpn.id
  target_network_cidr    = data.aws_subnet.lab-public-subnet.cidr_block
  authorize_all_groups   = true
}

# Provide VPN access to the internet
resource "aws_ec2_client_vpn_route" "lab-client-vpn-route-igw" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.lab-client-vpn.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   = data.aws_subnet.lab-public-subnet.id
}
