variable project-name {
  type        = string
  default     = "codebeneath-lab"
  description = "A string used for all resource names"
}

variable lab-vpc-id {
  type        = string
  nullable    = false
  description = "ID block for main vpc"
}

variable public-subnet-id {
  type        = string
  nullable    = false
  description = "Public subnet ID to use for the bootstrap server"
}

variable bootstap-ami {
  type        = string
  default     = ""
  description = "AMI ID to use for the bootstrap server. If blank, will use latest AL2023 image."
}

variable bootstrap-instance-type {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type to use for the bootstrap server"
}

variable bootstrap-key-name {
  type        = string
  nullable    = false
  description = "EC2 keypair to use to ssh into the bootstrap server"
}
