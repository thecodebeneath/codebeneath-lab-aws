terraform {
  backend "s3" {
    bucket = "codebeneath-dev" 
    key    = "lab/tf/instance-connect-tfstate"
    region = "us-east-2"
  }
}