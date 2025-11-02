module "codebeneath-aws" {
  source = "../../"

  project-name                = var.project-name
  vpc-cidr-block              = var.vpc-cidr-block
  public-subnet-2a-cidr-block = var.public-subnet-2a-cidr-block
  public-subnet-2b-cidr-block = var.public-subnet-2b-cidr-block
  public-subnet-2c-cidr-block = var.public-subnet-2c-cidr-block
  private-subnet-cidr-block   = var.private-subnet-cidr-block
}
