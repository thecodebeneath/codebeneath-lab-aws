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
  default     = "t2.small"
  description = "EC2 instance type to use for the kafka client ec2. Consider memory size to support java heap."
}

variable kafka-key-name {
  type        = string
  nullable    = false
  description = "EC2 keypair to use to ssh into the kafka client ec2"
}

variable dev-username {
  type        = string
  nullable    = false
  description = "Dev username that can assume Kafka client auth IAM role for debugging purposes"
}

variable enable-kafka-public-acccess {
  type        = string
  default    = "DISABLED"
  validation {
    condition = contains(["DISABLED", "SERVICE_PROVIDED_EIPS"], var.enable-kafka-public-acccess)
    error_message = "Environment must be either 'DISABLED' or 'SERVICE_PROVIDED_EIPS'."
  }
  description = "For security reasons, you can't turn on public access while creating an MSK cluster. You can turn on public access for an existing cluster."
}

variable msk-allowed-account {
  type        = string
  nullable    = false
  description = "Allowed accounts that are external to the MSK hosting account that may create a PrivateLink connection"
}