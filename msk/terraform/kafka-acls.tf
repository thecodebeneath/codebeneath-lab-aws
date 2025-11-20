# ---
# User `alice` connects to the MSK cluster using client_authentication method `scram`
# ---

resource "kafka_acl" "allow-scram-alice-topics" {
  acl_principal       = "User:alice"
  acl_host            = "*"
  acl_permission_type = "Allow"
  acl_operation       = "All"
  resource_type       = "Topic"
  resource_name       = "*"

  depends_on = [aws_iam_role.client-auth-bob-role]
}

resource "kafka_acl" "allow-scram-alice-groups" {
  acl_principal       = "User:alice"
  acl_host            = "*"
  acl_permission_type = "Allow"
  acl_operation       = "All"
  resource_type       = "Group"
  resource_name       = "*"

  depends_on = [aws_iam_role.client-auth-bob-role]
}

resource "kafka_topic" "codebeneath-alice-topic" {
  name               = "codebeneath-alice-topic"
  replication_factor = 3
  partitions         = 1

  depends_on = [aws_iam_role.client-auth-bob-role]
}
