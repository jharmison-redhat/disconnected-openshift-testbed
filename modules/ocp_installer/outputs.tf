output "ocp_installer" {
  value = {
    access_key = aws_iam_access_key.ocp_installer.id
    secret_key = aws_iam_access_key.ocp_installer.secret
  }
  sensitive   = true
  description = "The IAM Access Key ID and Secret for the OpenShift installation user."
}
