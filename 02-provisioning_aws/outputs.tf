output "ec2_public_ip" {
  description = "the public ip address of the ec2 instance."
  value       = aws_instance.server.public_ip
}

output "ec2_private_ip" {
  description = "the private ip address of the ec2 instance."
  value       = aws_instance.server.private_ip
}
