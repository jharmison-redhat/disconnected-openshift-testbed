# The proxy instance lives in the NAT subnet
resource "aws_instance" "proxy" {
  ami               = var.ami_id
  availability_zone = var.availability_zones[0]
  ebs_optimized     = true
  instance_type     = var.proxy_flavor
  monitoring        = false
  key_name          = var.ssh_key
  subnet_id         = aws_subnet.nat.id
  source_dest_check = false

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
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
    "${path.module}/squid.sh.tftpl", {
      ec2_user_password = var.instance_password
      allowed_urls      = var.allowed_urls
    }
  )

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
