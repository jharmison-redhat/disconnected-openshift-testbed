output "private_subnets" {
  value       = [aws_subnet.private.*.id]
  description = "The IDs of the subnets that route through the proxy."
}
output "public_subnets" {
  value       = [aws_subnet.public.*.id]
  description = "The IDs of the subnets that route through the IGW."
}
