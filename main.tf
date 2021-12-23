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
  owners      = ["309956199498"]

  filter {
    name    = "virtualization-type"
    values  = ["hvm"]
  }

  filter {
    name    = "name"
    values  = ["RHEL-${var.rhel_version}*_HVM-*-x86_64-*${var.ami_type}*"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_key_pair" "ec2_key" {
  key_name      = "${var.cluster_name}_${replace(var.cluster_domain, ".", "_")}"
  public_key    = var.public_key
}

module "vpc" {
  source              = "./modules/disconnected_vpc"
  availability_zones  = slice(data.aws_availability_zones.available.names, 1, 4)
  proxy_ami           = data.aws_ami.rhel.id
  proxy_flavor        = var.small_flavor
  proxy_ssh_key       = aws_key_pair.ec2_key.key_name
}
