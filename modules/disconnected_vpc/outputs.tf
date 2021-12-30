output "private_subnets" {
  value       = [for subnet in aws_subnet.private : subnet.id]
  description = "The IDs of the subnets that route through the proxy."
}

output "public_subnets" {
  value       = [for subnet in aws_subnet.public : subnet.id]
  description = "The IDs of the subnets that route through the IGW."
}
