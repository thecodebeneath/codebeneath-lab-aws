terraform {
  backend "s3" {
    bucket = "codebeneath-dev" 
    key    = "lab/tf/bootstrap-tfstate"
    region = "us-east-2"
  }
}