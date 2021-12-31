variable "ami_type" {
  type        = string
  description = "The AMI type to use, Access2 or Hourly. Availability may depend on your AWS account being linked with Red Hat Cloud Access."
  default     = "Hourly"

  validation {
    condition     = contains(["Hourly", "Access2"], var.ami_type)
    error_message = "The ami_type must be set to one of \"Hourly\" or \"Access2\"."
  }
}

variable "rhel_version" {
  type        = string
  description = "The major version of RHEL to use for the AMI selection."
  default     = "8"

  validation {
    condition     = contains(["8"], var.rhel_version)
    error_message = "The rhel_version must be set to one of the tested major versions in: [\"8\"]."
  }
}

variable "small_flavor" {
  type        = string
  description = "The AWS flavor to use for smaller instances (proxy, bastion)."
  default     = "t3.small"
}

variable "large_flavor" {
  type        = string
  description = "The AWS flavor to use for the larger instance (registry)."
  default     = "t3.large"
}

variable "public_key" {
  type        = string
  description = "The SSH public key string to use for the instances."
}

variable "instance_password" {
  type        = string
  description = "The password to set for the ec2-user on created instances."
  sensitive   = true
  default     = "" # Empty default means no password tfsec:ignore:GEN001
}

variable "cluster_name" {
  type        = string
  description = "The name you will be giving your OpenShift cluster in metadata.name in install-config.yaml (Note that all resources created are scoped under this subdomain)."
}

variable "cluster_domain" {
  type        = string
  description = "The name of the domain under which your OpenShift cluster will reside (Note that this needs to be a Hosted Zone managed in Route53)."
}

variable "extra_urls" {
  type        = list(string)
  description = "The list of URLs that will be allowed through the squid proxy, exactly as they would be in a squid whitelist (ex: \".amazonaws.com\")."
  default     = []
}

variable "redhat_username" {
  type        = string
  description = "The terms-based-registry username for using Red Hat container images."
}

variable "redhat_password" {
  type        = string
  description = "The terms-based registry password for using Red Hat container images."
  sensitive   = true
}

variable "registry_admin" {
  type        = object({ username = string, password = string, email = string })
  description = "The username, password, and email to configure for the admin user on the Quay instance."
  sensitive   = true
}
