output gitlab-public-eip {
    value = aws_eip.gitlab-eip.public_ip
    description = "The public IP of the gitlab EC2 instance"
}

output bootstrap-ami-id {
  value = data.aws_ami.al2023.id
  description = "The AMI id used for the bootstrap server"
}

output alb-dns-name {
  value = aws_lb.gitlab-alb.dns_name
  description = "The ALB dns name that Route53 should use for the gitlab record"
}

output alb-zone-id {
  value = aws_lb.gitlab-alb.zone_id
  description = "The ALB dns name that Route53 should use for the gitlab record"
}
