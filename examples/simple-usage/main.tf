module "testbed" {
  # When using this module, you should use the following commented out URL:
  # source = "github.com/jharmison-redhat/disconnected-openshift-testbed"
  #
  # When running this module for development, you should use the following URL
  # to indicate that you're using the working copy in the parent directory:
  source = "../.."

  # This is required to be provided
  public_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC5Da2XARZmB8KsjASv6MQoAS6sAXrw0yE5Y8ANJ5yTG"
  cluster_name   = var.cluster_name
  cluster_domain = var.cluster_domain
  # These enable us to set up and configure a Red Hat Quay instance
  redhat_username = var.redhat_username
  redhat_password = var.redhat_password
  registry_admin  = var.registry_admin
  cert_style      = var.cert_style
}

provider "aws" {
  region = "us-west-2"
  default_tags {
    tags = {
      Name    = "${var.cluster_name}.${var.cluster_domain}"
      Project = "disconnected-openshift-testbed"
    }
  }
}
