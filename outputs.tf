output "registry_instance" {
  value       = module.registry.registry_instance
  description = "Information about the registry instance."
  sensitive   = true
}

output "proxy_instance" {
  value       = module.vpc.proxy_instance
  description = "Information about the proxy instance."
  sensitive   = true
}

output "bastion_instance" {
  value       = module.vpc.bastion_instance
  description = "Information about the bastion instance."
  sensitive   = true
}

output "vpc" {
  value = {
    public_subnets     = module.vpc.public_subnets
    private_subnets    = module.vpc.private_subnets
    availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
    region             = data.aws_region.current.name
  }
  description = "Information about the provisioned VPC and its networks."
}

output "registry_bucket" {
  value       = module.registry.s3_bucket
  sensitive   = true
  description = "The AWS S3 bucket for the registry and IAM credentials required to access it."
}

output "ocp_installer" {
  value       = module.ocp_installer.ocp_installer
  sensitive   = true
  description = "The IAM Access Key ID and Secret for the OpenShift installation user."
}
