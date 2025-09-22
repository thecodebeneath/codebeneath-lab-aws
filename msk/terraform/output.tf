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

output msk-cluster-name {
  value = aws_msk_cluster.kafka-cluster.cluster_name
  description = "The MSK cluster name. Needs the cluster UUID to be complete"
}

output msk-cluster-uuid {
  value = aws_msk_cluster.kafka-cluster.cluster_uuid
  description = "The MSK cluster UUID. Needs the cluster name to be complete"
}
