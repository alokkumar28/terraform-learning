terraform {
  backend "s3" {
    bucket = "alok-my-unique-bucket-name-123456"
    region = "ap-south-1"
    key = "alok/terraform.tfstate"
    dynamodb_table = "terraform-locks"
  }
}