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
  ami                         = var.ami_id
  availability_zone           = var.availability_zone
  ebs_optimized               = true
  instance_type               = var.flavor
  monitoring                  = false
  key_name                    = var.ssh_key_name
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true #tfsec:ignore:AWS012
  tags = {
    Name = "${var.domain}-registry"
    Role = "registry"
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 500
    delete_on_termination = true
  }

  metadata_options {
    http_tokens = "required"
  }

  user_data = file("${path.module}/quay.sh")
}

resource "aws_route53_record" "registry" {
  zone_id         = var.hosted_zone
  name            = "${var.hostname}.${var.domain}"
  type            = "A"
  ttl             = "300"
  records         = aws_instance.registry.public_ip
  allow_overwrite = true
}
