terraform {
  backend "s3" {
    bucket = "codebeneath-dev" 
    key    = "lab/tf/s3-delete-test-tfstate"
    region = "us-east-2"
  }
}