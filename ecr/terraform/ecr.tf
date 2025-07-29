resource "aws_ecr_repository" "gitlab-repo" {
  name                 = "gitlab/gitlab-ce"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "${var.project-name}-gitlab-repo"
  }
}

resource "aws_ecr_repository" "gitlab-runner-repo" {
  name                 = "gitlab/gitlab-runner"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "${var.project-name}-gitlab-runner-repo"
  }
}

resource "aws_ecr_repository" "python-repo" {
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
  name                 = "hashicorp/terraform"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "${var.project-name}-terraform-repo"
  }
}
