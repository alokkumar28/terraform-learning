provider "aws" {
    region = "ap-south-1"
}

resource "aws_instance" "example" {
    ami           = var.ami_id
    instance_type = lookup(var.instance_type, terraform.workspace  , "t2.micro") # Default to t2.micro if environment not found

    tags = {
        Name = "ExampleInstance"
    }
}