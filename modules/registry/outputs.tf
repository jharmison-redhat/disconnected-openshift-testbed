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

output "s3_bucket" {
  value = {
    region     = aws_s3_bucket.registry.region
    bucket     = aws_s3_bucket.registry.bucket
    access_key = aws_iam_access_key.registry.id
    secret_key = aws_iam_access_key.registry.secret
  }
  sensitive   = true
  description = "The AWS S3 bucket and IAM credentials required to access it."
}
