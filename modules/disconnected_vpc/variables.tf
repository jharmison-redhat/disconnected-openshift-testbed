variable "vpc_cidr" {
  type        = string
  description = "The CIDR-notation subnet for the entire VPC."
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones to create subnets for."
}

variable "proxy_ami" {
  type        = string
  description = "The AMI to use for the proxy instance."

  validation {
    condition     = can(regex("^ami-", var.proxy_ami))
    error_message = "The proxy_ami value must be a valid AMI id, starting with \"ami-\"."
  }
}

variable "proxy_flavor" {
  type        = string
  description = "The instance type to use for the proxy instance."
  default     = "t3.small"
}

variable "proxy_ssh_key" {
  type        = string
  description = "The SSH public key to use for the proxy instance - must already exist as an aws_key_pair!"
}

variable "proxy_instance_password" {
  type        = string
  description = "The password to set for the ec2-user on the proxy instance."
  sensitive   = true
}
