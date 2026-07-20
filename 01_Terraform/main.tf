provider "aws" {
    region = "ap-south-1"
}

resource "aws_instance" "my_first_instance" {
    ami = "ami-0db56f446d44f2f09"
    instance_type = "t2.micro"
    tags = {
        Name = "MyFirstInstance"
    }
}
