output "Private_IPv4_address" {
  value       = aws_instance.private_test[0].private_ip
  description = "private IP"
}

output "Public_IPv4_dns_address" {
  value = aws_instance.public_test[0].public_dns
}
