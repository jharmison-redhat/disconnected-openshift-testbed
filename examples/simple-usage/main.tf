module "testbed" {
  # When using this module, you should use the following commented out URL:
  # source = "github.com/jharmison-redhat/disconnected-openshift-testbed"
  source          = "../.."

  public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC5Da2XARZmB8KsjASv6MQoAS6sAXrw0yE5Y8ANJ5yTG"
  ami_type        = "Access2"
  cluster_name    = var.cluster_name
  cluster_domain  = var.cluster_domain
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
