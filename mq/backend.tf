terraform {
  backend "s3" {
    bucket = "codebeneath-dev"
    key    = "lab/tf/mq-tfstate"
    region = "us-east-2"
  }
}