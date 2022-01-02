terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.70.0"
    }
  }
}

data "aws_subnet" "registry" {
  id = var.subnet_id
}

data "aws_vpc" "disco" {
  id = data.aws_subnet.registry.vpc_id
}
