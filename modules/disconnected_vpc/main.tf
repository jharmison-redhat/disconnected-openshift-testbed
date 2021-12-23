terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = {
      source    = "hashicorp/aws"
      version   = "3.70.0"
    }
  }
}

resource "aws_vpc" "vpc" {
  cidr_block            = var.vpc_cidr
  enable_dns_hostnames  = true
  enable_dns_support    = true
  instance_tenancy      = "default"
}

resource "aws_subnet" "private" {
  count                   = "${length(var.availability_zones)}"
  availability_zone       = var.availability_zones[count.index]
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${cidrsubnet(var.vpc_cidr, 4, count.index)}"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "public" {
  count                   = "${length(var.availability_zones)}"
  availability_zone       = var.availability_zones[count.index]
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${cidrsubnet(var.vpc_cidr, 4, length(var.availability_zones) + count.index)}"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "nat" {
  availability_zone       = var.availability_zones[0]
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${cidrsubnet(var.vpc_cidr, 4, length(var.availability_zones) * 2)}"
  map_public_ip_on_launch = true
}
