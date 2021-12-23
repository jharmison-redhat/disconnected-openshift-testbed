terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = {
      source    = "hashicorp/aws"
      version   = "3.70.0"
    }
  }
}

data "aws_ami" "rhel" {
  most_recent = true
  owners = ["309956199498"]
  filter {
    name    = "virtualization-type"
    values  = ["hvm"]
  }
  filter {
    name    = "name"
    values  = ["RHEL-${var.rhel_version}*_HVM-*-x86_64-*${var.ami_type}*"]
  }
}
