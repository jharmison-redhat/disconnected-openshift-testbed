terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

resource "random_string" "name_suffix" {
  length  = 5
  special = false
  upper   = false
}

resource "random_password" "instance_password" {
  length  = 16
  special = false
}

module "testbed" {
  # When using this module, you should use the following commented out URL:
  # source = "github.com/jharmison-redhat/disconnected-openshift-testbed"
  #
  # When running this module for development, you should use the following URL
  # to indicate that you're using the working copy in the parent directory:
  source = "../.."

  # This defaults to hourly, but using an AWS account with Cloud Access set up
  # means we can take advantage of cheaper instances like this:
  ami_type = "Access2"
  # This is required to be provided
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC5Da2XARZmB8KsjASv6MQoAS6sAXrw0yE5Y8ANJ5yTG"
  # These are required and here are generated semi-randomly to prevent naming
  # collisions
  cluster_name      = "${var.cluster_name}_${random_string.name_suffix.result}"
  cluster_domain    = var.cluster_domain
  instance_password = random_password.instance_password.result
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
      # I would like these to have obvious names, but alas....
      # https://github.com/hashicorp/terraform-provider-aws/issues/19583
      #      Name    = "${var.cluster_name}_${random_string.name_suffix.result}.${var.cluster_domain}"
      Name    = "${var.cluster_name}.${var.cluster_domain}"
      Project = "disconnected-openshift-testbed"
    }
  }
}
