data "aws_caller_identity" "current" {}

resource "aws_iam_role" "bootstrap-ec2-role" {
  name = "${var.project-name}-bootstrap-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
        }
      Effect = "Allow"
    }]
  })
  tags = {
    Name = "${var.project-name}-bootstrap-ec2-role"
  }
}

resource "aws_iam_policy" "bootstrap-ec2-policy" {
  #checkov:skip=CKV_AWS_290:Ensure IAM policies does not allow write access without constraints
  name        = "${var.project-name}-bootstrap-ec2-policy"
  description = "Policy to allow access to S3 and ECR"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets",
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::*/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = "arn:aws:ecr:*:${data.aws_caller_identity.current.account_id}:repository/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:DescribeRegistry",
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
  tags = {
    Name = "${var.project-name}-bootstrap-ec2-policy"
  }
}

resource "aws_iam_role_policy_attachment" "bootstrap-ec2-attach" {
  policy_arn = aws_iam_policy.bootstrap-ec2-policy.arn
  role       = aws_iam_role.bootstrap-ec2-role.name
}

resource "aws_iam_instance_profile" "bootstrap-ec2" {
  name = "${var.project-name}-bootstrap-ec2"
  role = aws_iam_role.bootstrap-ec2-role.name
  tags = {
    Name = "${var.project-name}-bootstrap-ec2"
  }
}
