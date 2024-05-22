output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.server.public_ip
}

output "ec2_private_ip" {
  description = "The private IP address of the EC2 instance."
  value       = aws_instance.server.private_ip
}