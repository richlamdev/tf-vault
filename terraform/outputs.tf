output "Private_IPv4_addresses" {
  value       = aws_instance.private_test[0].private_ip
  description = "private IP"
}

output "Client_VPN_Endpoint_ID" {
  value       = aws_ec2_client_vpn_endpoint.vpn.id
  description = "cvpn-endpoint id"
}
