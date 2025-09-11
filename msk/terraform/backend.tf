terraform {
  backend "s3" {
    bucket = "codebeneath-dev" 
    key    = "lab/tf/msk-tfstate"
    region = "us-east-2"
  }
}