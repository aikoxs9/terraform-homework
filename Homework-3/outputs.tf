output "ubuntu_public_ip" {
  value = aws_instance.ubuntu.public_ip
}

output "amazon_public_ip" {
  value = aws_instance.amazon.public_ip
}
