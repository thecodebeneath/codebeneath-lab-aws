terraform {
  # opentofu
  required_version = "~> 1.10.0"
  required_providers {
    kafka = {
      source  = "Mongey/kafka"
      version = "~> 0.13.1"
    }
  }
}

provider "kafka" {
  bootstrap_servers = split(",", "${data.terraform_remote_state.kafka-cluster.outputs.bootstrap-public-endpoints-iam}")
  tls_enabled       = true
  sasl_mechanism    = "aws-iam"
  sasl_aws_region   = "us-east-2"
  sasl_aws_profile  = "kafka-admin"
  # sasl_aws_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.client-auth-bob-role.name}"
}
