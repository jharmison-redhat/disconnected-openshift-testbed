terraform {
  required_version = ">= 1.4.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.58.0"
    }
  }
}

data "aws_subnet" "registry" {
  id = var.subnet_id
}

data "aws_vpc" "disco" {
  id = data.aws_subnet.registry.vpc_id
}
