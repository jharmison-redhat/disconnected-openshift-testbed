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

variable "instance_password" {
  type        = string
  description = "The password to set for the ec2-user on the registry instance."
  sensitive   = true
  default     = "" # Empty default means no password tfsec:ignore:GEN001
}

variable "cluster_name" {
  type        = string
  description = "The name you will be giving your OpenShift cluster in metadata.name in install-config.yaml. Will be used in the construction of DNS records for the registry in the public and private zones."
}

variable "cluster_domain" {
  type        = string
  description = "The name of the domain under which your OpenShift cluster will reside. Will be used in the construction of DNS records for the registry in the public and private zones."
}

variable "hostname" {
  type        = string
  description = "The hostname to use when building the instance and creating Route 53 records for it."
  default     = "registry"
}

variable "public_zone" {
  type        = string
  description = "The Route53 Hosted Zone ID which contains the domain for creating public registry records."
}

variable "private_zone_name" {
  type        = string
  description = "The Route53 Hosted Zone name which contains the domain for creating private registry records."
}

variable "private_zone_id" {
  type        = string
  description = "The Route53 Hosted Zone ID which contains the domain for creating private registry records."
}

variable "disk_gb" {
  type        = number
  description = "The size of the disk, in GB, for the registry instance. Since the registry instance is expected to use S3 storage, can be small."
  default     = 20
}
