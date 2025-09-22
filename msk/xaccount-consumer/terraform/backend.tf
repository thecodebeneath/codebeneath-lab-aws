terraform {
  backend "s3" {
    bucket = "codebeneath-mgmt-tf" 
    key    = "lab/tf/vpc-tfstate"
    region = "us-east-2"
  }
}