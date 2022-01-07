terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.70.0"
    }
  }
}

data "aws_ami" "rhel" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["RHEL-${var.rhel_version}*_HVM-*-x86_64-*${var.ami_type}*"]
  }
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_route53_zone" "public" {
  name = var.cluster_domain
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.cluster_name}_${replace(var.cluster_domain, ".", "_")}"
  public_key = var.public_key
}

module "vpc" {
  source             = "./modules/disconnected_vpc"
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
  ami_id             = data.aws_ami.rhel.id
  proxy_flavor       = var.small_flavor
  bastion_flavor     = var.large_flavor
  ssh_key            = aws_key_pair.ec2_key.key_name
  instance_password  = var.instance_password
  domain             = "${var.cluster_name}.${var.cluster_domain}"
  hosted_zone        = data.aws_route53_zone.public.id
}

module "registry" {
  source            = "./modules/quay_registry"
  availability_zone = data.aws_availability_zones.available.names[0]
  ami_id            = data.aws_ami.rhel.id
  flavor            = var.large_flavor
  ssh_key_name      = aws_key_pair.ec2_key.key_name
  instance_password = var.instance_password
  domain            = "${var.cluster_name}.${var.cluster_domain}"
  hosted_zone       = data.aws_route53_zone.public.id
  subnet_id         = module.vpc.public_subnets[0]
}
