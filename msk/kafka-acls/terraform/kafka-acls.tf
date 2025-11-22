# ---
# User `alice` connects to the MSK cluster using client_authentication method `scram`
# depends_on = [aws_iam_role.client-auth-bob-role]
# ---

# The 'kafka' provider needs the IAM endpoints and IAM role, so get them from the MSK cluster state.
data "terraform_remote_state" "kafka-cluster" {
  backend = "s3"
  config = {
    bucket = "codebeneath-dev" 
    key    = "lab/tf/msk-tfstate"
    region = "us-east-2"
  }
}

resource "kafka_acl" "deny-scram-alice-acls" {
  acl_principal       = "User:alice"
  acl_host            = "*"
  acl_permission_type = "Deny"
  acl_operation       = "All"
  resource_type       = "Cluster"
  resource_name       = "*"
}

resource "kafka_acl" "allow-scram-alice-topics" {
  acl_principal       = "User:alice"
  acl_host            = "*"
  acl_permission_type = "Allow"
  acl_operation       = "All"
  resource_type       = "Topic"
  resource_name       = "*"
}

resource "kafka_acl" "allow-scram-alice-groups" {
  acl_principal       = "User:alice"
  acl_host            = "*"
  acl_permission_type = "Allow"
  acl_operation       = "All"
  resource_type       = "Group"
  resource_name       = "*"
}

resource "kafka_topic" "codebeneath-alice-topic" {
  name               = "codebeneath-alice-topic"
  replication_factor = 3
  partitions         = 1
}
