variable project-name {
  type        = string
  default     = "codebeneath-lab"
  description = "A string used for all resource names"
}

variable vpc-cidr-block {
  type        = string
  nullable    = false
  description = "CIDR block for eice vpc"
}

variable private-subnet-cidr-block {
  type        = string
  nullable    = false
  description = "CIDR block for eice private subnet"
}

variable eice-ami {
  type        = string
  default     = ""
  description = "AMI ID to use for the eice server. If blank, will use latest AL2023 image."
}

variable eice-instance-type {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type to use for the eice server"
}

variable dev-username {
  type        = string
  nullable    = false
  description = "Dev username that can assume eice IAM role for ssh access"
}
