output "registry_hostname" {
  value       = module.testbed.registry_url
  description = "The public DNS hostname for the Quay registry."
}
