# ---
# User `bob` connects to the MSK cluster using client_authentication method `iam`
# ---
resource "aws_iam_role" "client-auth-bob-role" {
  name = "${var.project-name}-kafka-client-auth-bob-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid": "AllowDevsToAssumeRole",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.dev-username}"
        },
        "Action": "sts:AssumeRole"
      },
            {
        "Sid": "AllowCliServerToAssumeRole",
        "Effect": "Allow",
        "Principal": {
            "AWS": "${aws_iam_role.kafka-client-ec2-role.arn}"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name = "${var.project-name}-kafka-client-auth-bob-role"
  }
}

resource "aws_iam_policy" "client-auth-bob-policy" {
  #checkov:skip=CKV_AWS_290:Ensure IAM policies does not allow write access without constraints
  name        = "${var.project-name}-kafka-client-auth-bob-policy"
  description = "Policy to allow access to S3 and ECR"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
            "kafka-cluster:Connect",
            "kafka-cluster:AlterCluster",
            "kafka-cluster:DescribeCluster"
        ],
        "Resource": "arn:aws:kafka:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:cluster/${aws_msk_cluster.kafka-cluster.cluster_name}/${aws_msk_cluster.kafka-cluster.cluster_uuid}"
        },
        {
        "Effect": "Allow",
        "Action": [
            "kafka-cluster:DescribeTopic",
            "kafka-cluster:CreateTopic",
            "kafka-cluster:DeleteTopic",
            "kafka-cluster:WriteData",
            "kafka-cluster:ReadData"
        ],
        "Resource": "arn:aws:kafka:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:topic/${aws_msk_cluster.kafka-cluster.cluster_name}/${aws_msk_cluster.kafka-cluster.cluster_uuid}/*"
        },
        {
        "Effect": "Allow",
        "Action": [
            "kafka-cluster:AlterGroup",
            "kafka-cluster:DescribeGroup"
        ],
        "Resource": "arn:aws:kafka:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:group/${aws_msk_cluster.kafka-cluster.cluster_name}/${aws_msk_cluster.kafka-cluster.cluster_uuid}/*"
      }
    ]
  })
  tags = {
    Name = "${var.project-name}-kafka-client-auth-bob-policy"
  }
}

resource "aws_iam_role_policy_attachment" "client-auth-bob-policy-attach" {
  policy_arn = aws_iam_policy.client-auth-bob-policy.arn
  role       = aws_iam_role.client-auth-bob-role.name
}
