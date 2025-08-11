data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "gitlab-oidc" {
  url = "https://gitlab.codebeneath-labs.org"
  client_id_list = [
    "https://gitlab.codebeneath-labs.org",
  ]
}

resource "aws_iam_role" "gitlab-ec2-role" {
  name = "${var.project-name}-gitlab-ec2-role"
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
    Name = "${var.project-name}-gitlab-ec2-role"
  }
}

resource "aws_iam_policy" "gitlab-ec2-policy" {
  name        = "${var.project-name}-gitlab-ec2-policy"
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
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "arn:aws:ecr:::repository/*"
      }
    ]
  })
  tags = {
    Name = "${var.project-name}-gitlab-ec2-policy"
  }
}

resource "aws_iam_role_policy_attachment" "gitlab-ec2-attach" {
  policy_arn = aws_iam_policy.gitlab-ec2-policy.arn
  role       = aws_iam_role.gitlab-ec2-role.name
}

resource "aws_iam_instance_profile" "gitlab-ec2" {
  name = "${var.project-name}-gitlab-ec2"
  role = aws_iam_role.gitlab-ec2-role.name
  tags = {
    Name = "${var.project-name}-gitlab-ec2"
  }
}

# ---

resource "aws_iam_role" "gitlab-runner-role" {
  name = "${var.project-name}-gitlab-runner-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/gitlab.codebeneath-labs.org"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "gitlab.codebeneath-labs.org:sub": "project_path:codebeneath/tf:ref_type:branch:ref:main"
        }
      }
    }]
  })
  tags = {
    Name = "${var.project-name}-gitlab-runner-role"
  }
}

resource "aws_iam_policy" "gitlab-runner-policy" {
  #checkov:skip=CKV_AWS_290:Ensure IAM policies does not allow write access without constraints
  name        = "${var.project-name}-gitlab-runner-policy"
  description = "Policy to allow Gitlab runner to create terraform resources"
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
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "arn:aws:ecr:::repository/*"
      }
    ]
  })
  tags = {
    Name = "${var.project-name}-gitlab-runner-policy"
  }
}

resource "aws_iam_role_policy_attachment" "gitlab-runner-attach" {
  policy_arn = aws_iam_policy.gitlab-runner-policy.arn
  role       = aws_iam_role.gitlab-runner-role.name
}
