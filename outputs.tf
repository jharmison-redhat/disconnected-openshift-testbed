output "registry_url" {
  value       = module.registry.registry_hostname
  description = "The public DNS hostname of the Quay registry instance."
}
