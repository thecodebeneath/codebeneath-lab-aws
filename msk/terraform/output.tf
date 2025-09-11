output kafka-client-public-eip {
    value = aws_eip.kafka-client-eip.public_ip
    description = "The public IP of the kafka client EC2 instance"
}

output kafka-client-ami-id {
  value = data.aws_ami.al2023.id
  description = "The AMI id used for the kafka client ec2"
}

output workstation-ip {
  value = local.workstation-ip
  description = "The workstation IP to use for AWS security groups"
}
