output "registry_instance" {
  value       = module.testbed.registry_instance
  description = "Information about the registry instance."
  sensitive   = true
}
output "proxy_instance" {
  value       = module.testbed.proxy_instance
  description = "Information about the proxy instance."
  sensitive   = true
}
output "bastion_instance" {
  value       = module.testbed.bastion_instance
  description = "Information about the bastion instance."
  sensitive   = true
}
output "vpc" {
  value       = module.testbed.vpc
  description = "Information about the provisioned VPC and its networks."
}
