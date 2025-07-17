terraform {
  backend "s3" {
    bucket = "codebeneath-dev" 
    key    = "lab/tf/gitlab-tfstate"
    region = "us-east-2"
  }
}