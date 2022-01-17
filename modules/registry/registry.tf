# Exposing things to the internet is.... why we do this?
#tfsec:ignore:aws-vpc-no-public-egress-sg tfsec:ignore:aws-vpc-no-public-ingress-sg
resource "aws_security_group" "registry" {
  name        = "${var.hostname}.${var.domain}"
  description = "Allows inbound access for HTTP/S, in addition to SSH and inter-VPC traffic."
  vpc_id      = data.aws_vpc.disco.id

  ingress {
    description = "Allow incoming HTTP connections."
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow incoming HTTPS connections."
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow incoming SSH connections."
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow incoming pings."
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all inter-VPC ingresses."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.disco.cidr_block]
  }

  egress {
    description = "Allow full egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "registry" {
  ami                    = var.ami_id
  availability_zone      = var.availability_zone
  ebs_optimized          = true
  instance_type          = var.flavor
  monitoring             = false
  key_name               = var.ssh_key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.registry.id]
  tags = {
    Name = "${var.hostname}.${var.domain}"
    Role = "registry"
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.disk_gb
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

  user_data = templatefile(
    "${path.module}/setup.sh.tftpl", {
      hostname          = "${var.hostname}.${var.domain}"
      ec2_user_password = var.instance_password
    }
  )
}

resource "aws_eip" "registry" {
  vpc               = true
  instance          = aws_instance.registry.id
  network_interface = aws_instance.registry.primary_network_interface_id

  lifecycle {
    ignore_changes = [
      tags_all
    ]
  }
}

resource "aws_route53_record" "registry" {
  zone_id         = var.hosted_zone
  name            = "${var.hostname}.${var.domain}"
  type            = "A"
  ttl             = "300"
  records         = [aws_eip.registry.public_ip]
  allow_overwrite = true
}
