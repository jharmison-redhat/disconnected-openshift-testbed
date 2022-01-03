output "registry_instance" {
  value = {
    hostname   = "${var.hostname}.${var.domain}"
    ip         = aws_eip.registry.public_ip
    private_ip = aws_instance.registry.private_ip
    username   = "ec2-user"
    password   = var.instance_password
  }
  sensitive   = true
  description = "Information about the registry instance."
}
