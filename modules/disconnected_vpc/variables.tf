variable "vpc_cidr" {
  type        = string
  description = "The CIDR-notation subnet for the entire VPC."
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones to create subnets for."
}

variable "ami_id" {
  type        = string
  description = "The AMI to use for the proxy and bastion instances."

  validation {
    condition     = can(regex("^ami-", var.ami_id))
    error_message = "The proxy_ami value must be a valid AMI id, starting with \"ami-\"."
  }
}

variable "proxy_flavor" {
  type        = string
  description = "The instance type to use for the proxy instance."
  default     = "t3.small"
}

variable "bastion_flavor" {
  type        = string
  description = "The instance type to use for the isolated bastion host."
  default     = "t3.small"
}

variable "ssh_key" {
  type        = string
  description = "The SSH public key to use for the proxy and bastion instances - must already exist as an aws_key_pair!"
}

variable "instance_password" {
  type        = string
  description = "The password to set for the ec2-user on the proxy and bastion instances."
  sensitive   = true
  default     = "" # Empty default means no password tfsec:ignore:GEN001
}

variable "allowed_urls" {
  type        = list(string)
  description = "The exact lines that should be whitelisted on the Squid proxy that isolates the \"disconnected\" subnets. (ex: \".amazonaws.com\")"
  default     = []
}

variable "domain" {
  type        = string
  description = "The full name of the domain, which should be within one of your existing Route53 Hosted Zones, in which to create DNS records for the bastion."
}

variable "bastion_hostname" {
  type        = string
  description = "The hostname to use when building the bastion instance and creating Route 53 records for it."
  default     = "bastion"
}

variable "hosted_zone" {
  type        = string
  description = "The Route53 Hosted Zone ID which contains the domain for creating bastion records."
}
