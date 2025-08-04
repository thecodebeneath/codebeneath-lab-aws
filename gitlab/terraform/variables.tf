variable project-name {
  type        = string
  default     = "codebeneath-lab"
  description = "A string used for all resource names"
}

variable gitlab-ami {
  type        = string
  default     = ""
  description = "AMI ID to use for the gitlab server. If blank, will use latest AL2023 image."
}

variable gitlab-instance-type {
  type        = string
  default     = "t2.large"
  description = "EC2 instance type to use for the gitlab server"
}

variable gitlab-key-name {
  type        = string
  nullable    = false
  description = "EC2 keypair to use to ssh into the gitlab server"
}

variable gitlab-cert-domain {
  type        = string
  default     = "*.codebeneath-labs.org"
  description = "Wildcard domain of the Certificate Manager imported certificate"
}
