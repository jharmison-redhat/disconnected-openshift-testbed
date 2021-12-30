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
  associate_public_ip_address = true
  tags = {
    Name = "${var.cluster_domain}-${var.cluster_name}-registry"
    Role = "registry"
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 500
    delete_on_termination = true
  }

  user_data = file("quay.sh")
}
