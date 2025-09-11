variable project-name {
  type        = string
  default     = "codebeneath-lab"
  description = "A string used for all resource names"
}

variable kafka-client-ami {
  type        = string
  default     = ""
  description = "AMI ID to use for the kafka client ec2. If blank, will use latest AL2023 image."
}

variable kafka-client-instance-type {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type to use for the kafka client ec2"
}

variable kafka-key-name {
  type        = string
  nullable    = false
  description = "EC2 keypair to use to ssh into the kafka client ec2"
}
