# --------- Server -------------

resource "aws_ecr_repository" "gitlab-repo" {
  #checkov:skip=CKV_AWS_163:Ensure ECR image scanning on push is enabled
  #checkov:skip=CKV_AWS_51:Ensure ECR Image Tags are immutable
  #checkov:skip=CKV_AWS_136:Ensure that ECR repositories are encrypted using KMS
  #checkov:skip=CKV_AWS_163:Ensure ECR image scanning on push is enabled
  name                 = "gitlab/gitlab-ce"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "${var.project-name}-gitlab-repo"
  }
}

# --------- Runners -------------

resource "aws_ecr_repository" "gitlab-runner-repo" {
  #checkov:skip=CKV_AWS_163:Ensure ECR image scanning on push is enabled
  #checkov:skip=CKV_AWS_51:Ensure ECR Image Tags are immutable
  #checkov:skip=CKV_AWS_136:Ensure that ECR repositories are encrypted using KMS
  #checkov:skip=CKV_AWS_163:Ensure ECR image scanning on push is enabled
  name                 = "gitlab/gitlab-runner"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "${var.project-name}-gitlab-runner-repo"
  }
}

resource "aws_ecr_repository" "gitlab-runner-ecr-helper-repo" {
  #checkov:skip=CKV_AWS_163:Ensure ECR image scanning on push is enabled
  #checkov:skip=CKV_AWS_51:Ensure ECR Image Tags are immutable
  #checkov:skip=CKV_AWS_136:Ensure that ECR repositories are encrypted using KMS
  #checkov:skip=CKV_AWS_163:Ensure ECR image scanning on push is enabled
  name                 = "codebeneath/gitlab/gitlab-runner-ecr-helper"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "${var.project-name}-gitlab-runner-ecr-helper-repo"
  }
}

# --------- Executors -------------

resource "aws_ecr_repository" "python-repo" {
  #checkov:skip=CKV_AWS_163:Ensure ECR image scanning on push is enabled
  #checkov:skip=CKV_AWS_51:Ensure ECR Image Tags are immutable
  #checkov:skip=CKV_AWS_136:Ensure that ECR repositories are encrypted using KMS
  #checkov:skip=CKV_AWS_163:Ensure ECR image scanning on push is enabled
  name                 = "python"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "${var.project-name}-python-repo"
  }
}

resource "aws_ecr_repository" "terraform-repo" {
  #checkov:skip=CKV_AWS_163:Ensure ECR image scanning on push is enabled
  #checkov:skip=CKV_AWS_51:Ensure ECR Image Tags are immutable
  #checkov:skip=CKV_AWS_136:Ensure that ECR repositories are encrypted using KMS
  #checkov:skip=CKV_AWS_163:Ensure ECR image scanning on push is enabled
  name                 = "hashicorp/terraform"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "${var.project-name}-terraform-repo"
  }
}

resource "aws_ecr_repository" "terraform-awscli-repo" {
  #checkov:skip=CKV_AWS_163:Ensure ECR image scanning on push is enabled
  #checkov:skip=CKV_AWS_51:Ensure ECR Image Tags are immutable
  #checkov:skip=CKV_AWS_136:Ensure that ECR repositories are encrypted using KMS
  #checkov:skip=CKV_AWS_163:Ensure ECR image scanning on push is enabled
  name                 = "codebeneath/hashicorp/terraform-awscli"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "${var.project-name}-terraform-awscli-repo"
  }
}
