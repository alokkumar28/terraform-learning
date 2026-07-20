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
