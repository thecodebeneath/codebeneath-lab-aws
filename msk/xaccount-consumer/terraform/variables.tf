variable project-name {
  type        = string
  default     = "mgmt-tf"
  description = "A string used for all resource names"
}

variable vpc-cidr-block {
  type        = string
  nullable    = false
  description = "CIDR block for main vpc"
}

variable public-subnet-2a-cidr-block {
  type        = string
  nullable    = false
  description = "CIDR block for public vpc"
}

variable public-subnet-2b-cidr-block {
  type        = string
  nullable    = false
  description = "CIDR block for public vpc"
}

variable private-subnet-cidr-block {
  type        = string
  nullable    = false
  description = "CIDR block for private vpc"
}

variable bootstap-ami {
  type        = string
  default     = ""
  description = "AMI ID to use for the bootstrap server. If blank, will use latest AL2023 image."
}

variable bootstrap-instance-type {
  type        = string
  default     = "t2.small"
  description = "EC2 instance type to use for the bootstrap server. Consider memory size to support java heap."
}

variable bootstrap-key-name {
  type        = string
  nullable    = false
  description = "EC2 keypair to use to ssh into the bootstrap server"
}

variable msk-target-cluster-arn {
  type        = string
  nullable    = false
  description = "MSK target cluster ARN that has enabled multi-vpc private connectivity from other accounts"
}
