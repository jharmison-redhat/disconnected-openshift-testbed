terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.70.0"
    }
  }
}

resource "aws_instance" "registry" {
  ami               = var.ami_id
  availability_zone = var.availability_zone
  ebs_optimized     = true
  instance_type     = var.flavor
  monitoring        = false
  key_name          = var.ssh_key_name
  subnet_id         = var.subnet_id
  tags = {
    # This is.... deeply frustrating.
    # https://github.com/hashicorp/terraform-provider-aws/issues/19583
    Name = "registry"
    Role = "registry"
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 500
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  lifecycle {
    ignore_changes = [
      # AWS updates these dynamically, do not interfere.
      tags["ServiceOwner"],
      tags_all["ServiceOwner"],
      root_block_device["tags"]
    ]
  }

  user_data = file("${path.module}/quay.sh")
}

resource "aws_eip" "registry" {
  vpc               = true
  instance          = aws_instance.registry.id
  network_interface = aws_instance.registry.primary_network_interface_id
}

resource "aws_route53_record" "registry" {
  zone_id         = var.hosted_zone
  name            = "${var.hostname}.${var.domain}"
  type            = "A"
  ttl             = "300"
  records         = [aws_instance.registry.public_ip]
  allow_overwrite = true
}
