provider "aws" {
  region = ap-south-1
}

module "ec2_instance" {
  source = "./modules/ec2_instance"
  ami_value = "ami-0db56f446d44f2f09"
  instance_type_value = "t2.micro"
  key_name_value = "alok-aws-keypair"
}