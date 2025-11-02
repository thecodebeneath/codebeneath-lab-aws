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

variable public-subnet-2a-cidr-block {
  type        = string
  nullable    = false
  description = "CIDR block for public subnet 1 / AZ-2a"
}

variable public-subnet-2b-cidr-block {
  type        = string
  nullable    = false
  description = "CIDR block for public subnet 2 / AZ-2b"
}

variable public-subnet-2c-cidr-block {
  type        = string
  nullable    = false
  description = "CIDR block for public subnet 3 / AZ-2c"
}

variable private-subnet-cidr-block {
  type        = string
  nullable    = false
  description = "CIDR block for private subnet"
}
