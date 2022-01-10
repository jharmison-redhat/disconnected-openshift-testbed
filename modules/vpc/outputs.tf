output "private_subnets" {
  value       = [for subnet in aws_subnet.private : subnet.id]
  description = "The IDs of the subnets that route through the proxy."
}

output "public_subnets" {
  value       = [for subnet in aws_subnet.public : subnet.id]
  description = "The IDs of the subnets that route through the IGW."
}

output "proxy_instance" {
  value = {
    hostname   = "${var.proxy_hostname}.${var.domain}"
    ip         = aws_eip.proxy.public_ip
    private_ip = aws_instance.proxy.private_ip
    username   = "ec2-user"
    password   = var.instance_password
  }
  description = "Information about the proxy instance."
  sensitive   = true
}

output "bastion_instance" {
  value = {
    hostname   = "${var.bastion_hostname}.${var.domain}"
    private_ip = aws_instance.bastion.private_ip
    username   = "ec2-user"
    password   = var.instance_password
  }
  description = "Information about the bastion instance."
  sensitive   = true
}
