output "ec2_public_ip1" {
  description = "the public ip address of the ec2 instance."
  value       = aws_instance.server[0].public_ip
}

output "ec2_private_ip1" {
  description = "the private ip address of the ec2 instance."
  value       = aws_instance.server[0].private_ip
}

output "ec2_public_ip2" {
  description = "the public ip address of the ec2 instance."
  value       = aws_instance.server[1].public_ip
}

output "ec2_private_ip2" {
  description = "the private ip address of the ec2 instance."
  value       = aws_instance.server[1].private_ip
}