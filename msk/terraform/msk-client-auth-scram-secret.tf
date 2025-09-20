# ---
# User `alice` connects to the MSK cluster using client_authentication method `scram`
# ---
resource "random_password" "password" {
  length = 20
  special = false
}

resource "aws_kms_key" "secret-key" {
  description = "MSK client SASL/SCRAM auth secret key"
}

resource "aws_kms_alias" "secret-key-alias" {
  name = "alias/${var.project-name}-msk-secret-key"
  target_key_id = aws_kms_key.secret-key.id
}

resource "aws_secretsmanager_secret" "msk-scram-auth" {
  name = "AmazonMSK_${var.project-name}-msk-scram-secret"
  kms_key_id = aws_kms_key.secret-key.id
}

resource "aws_secretsmanager_secret_version" "alice" {
  secret_id = aws_secretsmanager_secret.msk-scram-auth.id
  secret_string = <<EOF
  {
    "username": "alice",
    "password": "${random_password.password.result}"
  }
  EOF
}

resource "aws_msk_scram_secret_association" "msk-alice-scram-secret" {
  cluster_arn = aws_msk_cluster.kafka-cluster.arn
  secret_arn_list = [ aws_secretsmanager_secret.msk-scram-auth.arn ]
}

data "aws_iam_policy_document" "allow-msk-scram-secret-policy" {
  statement {
    sid = "AWSKafkaResourcePolicy"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["kafka.amazonaws.com"]
    }
    actions=["secretsmanager:GetSecretValue"]
    resources = ["${aws_secretsmanager_secret.msk-scram-auth.arn}"] 
  }
}

resource "aws_secretsmanager_secret_policy" "msk-scram-auth-policy" {
  secret_arn = aws_secretsmanager_secret.msk-scram-auth.arn
  policy = data.aws_iam_policy_document.allow-msk-scram-secret-policy.json
}
