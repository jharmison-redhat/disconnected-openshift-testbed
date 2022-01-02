variable "cluster_name" { default = "disco" }
variable "cluster_domain" { default = "redhat4govaws.io" }

variable "redhat_username" {
  type        = string
  description = "The terms-based-registry username for using Red Hat container images."
}

variable "redhat_password" {
  type        = string
  description = "The terms-based registry password for using Red Hat container images."
  sensitive   = true
}

variable "registry_admin" {
  type        = object({ username = string, password = string, email = string })
  description = "The username, password, and email to configure for the admin user on the Quay instance."
  sensitive   = true
}

variable "cert_style" {
  type        = string
  description = "The style of certificate to use for the registry instance."
  default     = "selfsigned"
  validation {
    condition     = contains(["letsencrypt", "selfsigned"], var.cert_style)
    error_message = "The cert_style value must be one of letsencrypt or selfsigned."
  }
}
