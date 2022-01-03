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
  public_key = var.public_key
  # These are required and here are generated semi-randomly to prevent naming
  # collisions
  cluster_name      = "${var.cluster_name}_${random_string.name_suffix.result}"
  cluster_domain    = var.cluster_domain
  instance_password = random_password.instance_password.result
}

provider "aws" {
  region = var.region
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
