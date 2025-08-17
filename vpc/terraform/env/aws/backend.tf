terraform {
  backend "s3" {
    bucket = "codebeneath-dev" 
    key    = "lab/tf/vpc-tfstate"
    region = "us-east-2"
  }
}