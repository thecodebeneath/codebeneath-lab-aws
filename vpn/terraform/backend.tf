terraform {
  backend "s3" {
    bucket = "codebeneath-dev" 
    key    = "lab/tf/vpn-tfstate"
    region = "us-east-2"
  }
}