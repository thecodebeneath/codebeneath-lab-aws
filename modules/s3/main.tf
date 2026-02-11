resource "aws_s3_bucket" "prevent_destroy_bucket" {
  bucket = "my-unique-s3-bucket-name-prevent-destroy-12345" # Replace with a globally unique name

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = "my-unique-s3-bucket-name-prevent-destroy"
    Environment = "Dev"
  }
}

