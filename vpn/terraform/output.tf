output lab-vpn-id {
    value = aws_ec2_client_vpn_endpoint.lab-client-vpn.id
    description = "The ID of the lab client VPN endpoint"
}
