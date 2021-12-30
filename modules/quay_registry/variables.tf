variable "ami_id" {
  type        = string
  description = "The ID of the AMI that should be used for the registry."

  validation {
    condition     = can(regex("^ami-", var.ami_id))
    error_message = "The proxy_ami value must be a valid AMI id, starting with \"ami-\"."
  }
}

variable "subnet_id" {
  type        = string
  description = "The ID of the existing VPC subnet into which the instance should associate its default interface."
}

variable "availability_zone" {
  type        = string
  description = "The availability zone into which the registry instance should be placed - should align with the subnet's zone."
}

variable "flavor" {
  type        = string
  description = "The instance type to use for the registry instance."
  default     = "t3.large"
}

variable "ssh_key_name" {
  type        = string
  description = "The SSH public key to use for the proxy instance - must already exist as an aws_key_pair!"
}

variable "domain" {
  type        = string
  description = "The full name of the domain, which should be within one of your existing Route53 Hosted Zones, in which to create DNS records for the registry."
}

variable "hostname" {
  type        = string
  description = "The hostname to use when building the instance and creating Route 53 records for it."
  default     = "registry"
}

variable "hosted_zone" {
  type        = string
  description = "The Route53 Hosted Zone ID which contains the domain for creating registry records."
}
