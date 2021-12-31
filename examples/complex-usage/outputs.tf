output "registry_hostname" {
  value       = module.testbed.registry_url
  description = "The public DNS hostname for the Quay registry."
}

output "instance_password" {
  value       = random_password.instance_password.result
  description = "The randomly generated password used for instances."
  sensitive   = true
}
