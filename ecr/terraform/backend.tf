terraform {
  backend "s3" {
    bucket = "codebeneath-dev" 
    key    = "lab/tf/ecr-tfstate"
    region = "us-east-2"
  }
}