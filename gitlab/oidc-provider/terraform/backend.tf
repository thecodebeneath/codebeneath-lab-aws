terraform {
  backend "s3" {
    bucket = "codebeneath-dev" 
    key    = "lab/tf/gitlab-oidc-tfstate"
    region = "us-east-2"
  }
}