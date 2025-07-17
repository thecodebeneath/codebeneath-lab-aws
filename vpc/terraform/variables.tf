variable project-name {
  type        = string
  default     = "codebeneath-lab"
  description = "A string used for all resource names"
}

variable vpc-cidr-block {
  type        = string
  nullable    = false
  description = "CIDR block for main vpc"
}

variable public-subnet-cidr-block {
  type        = string
  nullable    = false
  description = "CIDR block for public vpc"
}

variable private-subnet-cidr-block {
  type        = string
  nullable    = false
  description = "CIDR block for private vpc"
}
