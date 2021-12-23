variable "aws_region" {
  type = string
  description = "The AWS region into which we should deploy"
  default = "us-west-2"
}

variable "rhel_ami" {
  type = map(string)
  description = "The RHEL AMI to use in the selected region"
  default = {
    us-east-1 = "ami-06f1e6f8b3457ae7c"
    us-east-2 = "ami-01884d450e98ddd02"
    us-west-2 = "ami-075c0197520b50913"
    us-west-2 = "ami-075c0197520b50913"
    ca-central-1 = "ami-03fbe498294f3a558"
    ap-southeast-2 = "ami-0ad5c7d0eee639fe1"
    eu-west-2 = "ami-01f088d00bcd2b83d"
  }
}

variable "small_flavor" {
  type = string
  description = "The AWS flavor to use for smaller instances (proxy, bastion)"
  default = "t3.small"
}

variable "large_flavor" {
  type = string
  description = "The AWS flavor to use for the larger instance (registry)"
  default = "t3.large"
}

variable "public_key" {
  type = string
  description = "The SSH public key string to use for the instances"
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC5Da2XARZmB8KsjASv6MQoAS6sAXrw0yE5Y8ANJ5yTG"
}

variable "cluster_name" {
  type = string
  description = "The name you will be giving your OpenShift cluster in metadata.name in install-config.yaml (Note that all resources created are scoped under this subdomain)"
  default = "disco"
}

variable "cluster_domain" {
  type = string
  description = "The name of the domain under which your OpenShift cluster will reside (Note that this needs to be a Hosted Zone managed in Route53)"
  default = "redhat4govaws.io"
}
