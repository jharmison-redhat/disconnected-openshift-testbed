output "registry_hostname" {
  value       = aws_route53_record.registry.name
  description = "The public DNS hostname for the Quay registry."
}
