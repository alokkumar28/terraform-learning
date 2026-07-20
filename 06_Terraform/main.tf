provider "aws" {
  region = "ap-south-1"
}

variable "instance_type" {
    description = "Type of EC2 instance to launch"
    type = map(string)
    default = {
        "dev" = "t2.micro"
        "prod" = "t2.medium"    
        "stag" = "t2.small"
    }    
}


variable "ami_id" {
    description = "AMI ID to use for the EC2 instance"
}

module "ec2_instance" {
  source        = "./modules/ec2_instance"
  instance_type = lookup(var.instance_type, terraform.workspace, "t2.micro") # Default to t2.micro if environment not found
  ami_id        = var.ami_id
}