output bootstrap-public-ip {
    value = aws_instance.bootstrap.public_ip
    description = "The public IP of the bootstrap EC2 instance"
}

output bootstrap-ami-id {
  value = data.aws_ami.al2023.id
  description = "The AMI id used for the bootstrap server"
}