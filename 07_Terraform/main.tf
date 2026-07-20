provider "aws" {
    region = "ap-south-1"
}



provider "vault" {
  address = "http://13.233.28.195:8200"
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id = "1b01e6ae-f38b-ac57-edab-7f916da4b242"
      secret_id = "05cfc441-e8f3-7400-ce88-f2439aa195f5"
    }
  }
}


data "vault_kv_secret_v2" "secret_key" {
  mount = "secret"
  name  = "secret-key"
}

resource "aws_instance" "my_instance" {
  ami           = "ami-01a00762f46d584a1"
  instance_type = "t3.micro"

  tags = {
    Name   = "test"
    Secret = data.vault_kv_secret_v2.secret_key.data["alok"]
  }
}

data "vault_kv_secret_v2" "s3_secret" {
  mount = "secret"
  name  = "s3-secret"
}
resource "aws_s3_bucket" "bucket" {
  bucket = data.vault_kv_secret_v2.s3_secret.data["bucket-name"]
}