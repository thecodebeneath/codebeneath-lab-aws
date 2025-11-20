terraform {
  # opentofu
  required_version = "~> 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
    kafka = {
      source  = "Mongey/kafka"
      version = "~> 0.13.1"
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

provider "random" { }

provider "kafka" {
  bootstrap_servers = split(",", "${aws_msk_cluster.kafka-cluster.bootstrap_brokers_public_sasl_iam}")
  tls_enabled       = true
  sasl_mechanism    = "aws-iam"
  sasl_aws_region   = "us-east-2"
  sasl_aws_profile  = "kafka-admin"
  # sasl_aws_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.client-auth-bob-role.name}"
}
