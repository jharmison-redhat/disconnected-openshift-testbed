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

# - We're heavily restricting access to this bucket, and encrypting it will
#   only slow it down and make configuration more complex
# - Logging is unnecessarily complex for this simple environment
# - Versioning doesn't matter as blobs used by the registry will be globally
#   unique anyways, thanks to hashing
#tfsec:ignore:aws-s3-enable-bucket-encryption tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "registry" {
  force_destroy = true
  bucket        = "${var.domain}-registry"
  acl           = "private"
}

resource "aws_s3_bucket_public_access_block" "registry" {
  bucket = aws_s3_bucket.registry.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "registry" {
  name = "${var.domain}-registry"
  path = "/"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Effect" : "Allow",
      }
    ]
  })
}

resource "aws_iam_role_policy" "registry" {
  name = "${var.domain}-registry"
  role = aws_iam_role.registry.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListStorageLensConfigurations",
          "s3:ListAccessPointsForObjectLambda",
          "s3:GetAccessPoint",
          "s3:PutAccountPublicAccessBlock",
          "s3:GetAccountPublicAccessBlock",
          "s3:ListAllMyBuckets",
          "s3:ListAccessPoints",
          "s3:ListJobs",
          "s3:PutStorageLensConfiguration",
          "s3:ListMultiRegionAccessPoints",
          "s3:CreateJob"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : "${aws_s3_bucket.registry.arn}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : "${aws_s3_bucket.registry.arn}"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "registry" {
  name = "${var.domain}-registry"
  role = "${var.domain}-registry"
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
  iam_instance_profile   = aws_iam_instance_profile.registry.name
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

  user_data = templatefile(
    "${path.module}/quay.sh.tftpl", {
      ec2_user_password = var.instance_password
      redhat_username   = var.redhat_username
      redhat_password   = var.redhat_password
      registry_admin    = var.registry_admin
      registry_hostname = "${var.hostname}.${var.domain}"
    }
  )
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
  records         = [aws_eip.registry.public_ip]
  allow_overwrite = true
}
