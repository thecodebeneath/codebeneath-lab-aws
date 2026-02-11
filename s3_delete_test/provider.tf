terraform {
  # opentofu
  required_version = "~> 1.11.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      Environment = "codebeneath-lab"
      ManagedBy   = "terraform"
    }
  }
}
