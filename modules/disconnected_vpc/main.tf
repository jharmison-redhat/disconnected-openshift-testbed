terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.70.0"
    }
  }
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
}

# Creates private subnets for each az
resource "aws_subnet" "private" {
  count                   = length(var.availability_zones)
  availability_zone       = var.availability_zones[count.index]
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  map_public_ip_on_launch = false
  tags = {
    Role = "private"
  }
}

# Creates public subnets for each az
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  availability_zone       = var.availability_zones[count.index]
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, length(var.availability_zones) + count.index)
  map_public_ip_on_launch = true
  tags = {
    Role = "public"
  }
}

# Creates a single "NAT" subnet for hosting our proxy
resource "aws_subnet" "nat" {
  availability_zone       = var.availability_zones[0]
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, length(var.availability_zones) * 2)
  map_public_ip_on_launch = true
  tags = {
    Role = "nat"
  }
}

# The public subnets and NAT subnet should be able to reach the internet
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Role = "public"
  }
}

# And the default route table should use that gateway
resource "aws_default_route_table" "public" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Role = "public"
  }
}

# The proxy instance lives in the NAT subnet
resource "aws_instance" "proxy" {
  ami                         = var.proxy_ami
  availability_zone           = var.availability_zones[0]
  ebs_optimized               = true
  instance_type               = var.proxy_flavor
  monitoring                  = false
  key_name                    = var.proxy_ssh_key
  subnet_id                   = aws_subnet.nat.id
  associate_public_ip_address = true
  source_dest_check           = false

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  user_data = file("${path.module}/squid.sh")

  tags = {
    Role = "proxy"
  }
}

# And the private subnets should route through the proxy
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.proxy.id
  }

  tags = {
    Role = "private"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
