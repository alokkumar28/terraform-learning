provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "my_ec3_instance"{
    ami = var.ami_value
    instance_type = var.instance_type_value
    key_name = var.key_name_value
}