output "public-ip" {
  value = aws_instance.my_ec3_instance.public_ip
}