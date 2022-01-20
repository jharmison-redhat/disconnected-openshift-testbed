output "private_subnets" {
  value       = aws_subnet.private
  description = "Details about the subnets that are isolated by routing through the proxy."
}

output "public_subnets" {
  value       = aws_subnet.public
  description = "Details about the subnets that route through the IGW to the public internet."
}

output "proxy_instance" {
  value = {
    hostname   = "${var.proxy_hostname}.${var.cluster_name}.${var.cluster_domain}"
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
    hostname   = "${var.bastion_hostname}.${var.cluster_name}.${var.cluster_domain}"
    private_ip = aws_instance.bastion.private_ip
    username   = "ec2-user"
    password   = var.instance_password
  }
  description = "Information about the bastion instance."
  sensitive   = true
}

output "private_zone" {
  value       = aws_route53_zone.private
  description = "The private Hosted Zone created for the VPC."
}
