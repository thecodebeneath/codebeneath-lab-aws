terraform {
  backend "s3" {
    bucket = "codebeneath-dev" 
    key    = "lab/tf/kafka-acls-tfstate"
    region = "us-east-2"
  }
}