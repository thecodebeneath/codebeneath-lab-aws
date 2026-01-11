data "aws_caller_identity" "current" {}

resource "aws_iam_role" "eice-workstation-role" {
  name = "${var.project-name}-eice-workstation-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      "Sid": "AllowDevsToAssumeRole",
      "Effect": "Allow",
      "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.dev-username}"
      },
      "Action": "sts:AssumeRole"
    }]
  })
  tags = {
    Name = "${var.project-name}-eice-workstation-role"
  }
}

resource "aws_iam_policy" "eice-workstation-role-policy" {
  #checkov:skip=CKV_AWS_290:Ensure IAM policies does not allow write access without constraints
  name        = "${var.project-name}-eice-workstation-role-policy"
  description = "Policy to allow workstation role to connect to EC2 via eice"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
          "Effect": "Allow",
          "Action": "ec2-instance-connect:SendSSHPublicKey",
          "Resource": "arn:aws:ec2:us-east-2:${data.aws_caller_identity.current.account_id}:instance/${aws_instance.eice-ec2.id}",
          "Condition": {
              "StringEquals": { "ec2:osuser": "ec2-user" }
          }
      },
      {
          "Effect": "Allow",
          "Action": "ec2-instance-connect:OpenTunnel",
          "Resource": "arn:aws:ec2:us-east-2:${data.aws_caller_identity.current.account_id}:instance-connect-endpoint/${aws_ec2_instance_connect_endpoint.lab-eice.id}",
          "Condition": {
              "NumericEquals": { "ec2-instance-connect:remotePort": "22" }
          }
      },
      {
          "Effect": "Allow",
          "Action": [
              "ec2:DescribeInstances",
              "ec2:DescribeInstanceConnectEndpoints"
          ],
          "Resource": "*"
      }
    ]
  })
  tags = {
    Name = "${var.project-name}-eice-workstation-role-policy"
  }
}

resource "aws_iam_role_policy_attachment" "eice-policy-attach" {
  policy_arn = aws_iam_policy.eice-workstation-role-policy.arn
  role       = aws_iam_role.eice-workstation-role.name
}
