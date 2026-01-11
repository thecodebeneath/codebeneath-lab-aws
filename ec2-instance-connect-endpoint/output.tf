output eice-private-eip {
    value = aws_instance.eice-ec2.private_ip
    description = "The private IP of the eice EC2 instance"
}

output eice-ami-id {
  value = data.aws_ami.al2023.id
  description = "The AMI id used for the eice server"
}

output eice-workstation-role {
  value = aws_iam_role.eice-workstation-role.arn
  description = "ARN of the eice IAM role used to connect to the eice EC2"
}
