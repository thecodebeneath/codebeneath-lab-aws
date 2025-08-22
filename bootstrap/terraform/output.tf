output bootstrap-public-eip {
    value = aws_eip.bootstrap-eip.public_ip
    description = "The public IP of the bootstrap EC2 instance"
}

output bootstrap-ami-id {
  value = data.aws_ami.al2023.id
  description = "The AMI id used for the bootstrap server"
}

output workstation-ip {
  value = local.workstation-ip
  description = "The workstation IP to use for AWS security groups"
}
