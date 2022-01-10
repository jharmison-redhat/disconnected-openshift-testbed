# Disconnected OpenShift Testbed

A terraform module for creating a testbed for Disconnected OpenShift clusters. It configures resources on Amazon to emulate a disconnected environment, providing the means for a user to practice or demonstrate "sneakernet" use-cases for getting OpenShift content into a disconnected environment on AWS, while still allowing for API connectivity. This is similar enough to other IPI use cases (Metal3, vSphere) that are very common on other infrastructures, as well as closely related to the experience on "disconnected" AWS overlays, to be a meaningful test bench.

For an example of this Terraform module's intended use cases, including more robust configuration post-provisioning please see the [oc-mirror E2E testing framework repository](https://github.com/jharmison-redhat/oc-mirror-e2e).

## Basic Information

### Environment Prerequisites

- Terraform >= 0.14.0
- An AWS profile defined in `~/.aws/credentials` or IAM credentials exported
  - This AWS profile needs to have a significant amount of privilege
  - You should have a Route53 Hosted Zone available on the account

## What do I get?

This terraform module creates a VPC with 7 subnets across 3 availability zones:

- Three of those subnets (one in each zone) are on a traditional AWS IGW that enables outbound internet access
  - These are the "connected" subnets
- One of those subnets is the designated NAT subnet, with a unique CIDR, access to the IGW, and source/dest check disabled on AWS
- Three of them (one in each zone) are on an AWS subnet with a route set to the instance in the NAT subnet
  - These are the "isolated" subnets

Three instances are stood up:

- One in a "connected" subnet, designated to be a registry
  - TCP ports 443 and 80 are allowed to this instance
  - An elastic IP and Route53 record are created for this instance
  - You need to configure this as a registry yourself
- One in the NAT subnet, designated to be the proxy for isolated subnets
  - An elastic IP and Route53 record are created for this instance
  - You need to configure this as a proxy yourself
- One in an "isolated" subnet, designated to be the disconnected bastion
  - You need to ensure that proxy configuration meets your expectations for this instance

An S3 bucket and IAM credentials to use it (read/write) are created:

- These are designed for use by the registry

### Example usage

Reference the module from your own terraform, with an initialized AWS provider. An example terraform file might look like this:

```hcl
module "testbed" {
  source = "github.com/jharmison-redhat/disconnected-openshift-testbed"

  public_key     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC5Da2XARZmB8KsjASv6MQoAS6sAXrw0yE5Y8ANJ5yTG"
  cluster_name   = "disco"
  cluster_domain = "redhat4govaws.io"
}

provider "aws" {
  region = "us-west-2"
  default_tags {
    tags = {
      Name    = "disco.redhat4govaws.io"
      Project = "disconnected-openshift-testbed"
    }
  }
}
```

Some more robust examples, including parametrized ones with outputs, are available in the `examples` directory. Terraform outputs are expected to be required for consumption by follow-on automation.

## Module Documentation

<!-- BEGIN_ROOT_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 3.70.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.70.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_registry"></a> [registry](#module\_registry) | ./modules/registry | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./modules/vpc | n/a |

### Resources

| Name | Type |
|------|------|
| [aws_key_pair.ec2_key](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/key_pair) | resource |
| [aws_ami.rhel](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/data-sources/availability_zones) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/data-sources/region) | data source |
| [aws_route53_zone.public](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/data-sources/route53_zone) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_type"></a> [ami\_type](#input\_ami\_type) | The AMI type to use, Access2 or Hourly. Availability may depend on your AWS account being linked with Red Hat Cloud Access. | `string` | `"Hourly"` | no |
| <a name="input_cluster_domain"></a> [cluster\_domain](#input\_cluster\_domain) | The name of the domain under which your OpenShift cluster will reside (Note that this needs to be a Hosted Zone managed in Route53). | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name you will be giving your OpenShift cluster in metadata.name in install-config.yaml (Note that all resources created are scoped under this subdomain). | `string` | n/a | yes |
| <a name="input_instance_password"></a> [instance\_password](#input\_instance\_password) | The password to set for the ec2-user on created instances. | `string` | `""` | no |
| <a name="input_large_flavor"></a> [large\_flavor](#input\_large\_flavor) | The AWS flavor to use for the larger instance (registry, bastion). | `string` | `"t3.large"` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | The SSH public key string to use for the instances. | `string` | n/a | yes |
| <a name="input_rhel_version"></a> [rhel\_version](#input\_rhel\_version) | The major version of RHEL to use for the AMI selection. | `string` | `"8"` | no |
| <a name="input_small_flavor"></a> [small\_flavor](#input\_small\_flavor) | The AWS flavor to use for smaller instance (proxy). | `string` | `"t3.small"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_instance"></a> [bastion\_instance](#output\_bastion\_instance) | Information about the bastion instance. |
| <a name="output_proxy_instance"></a> [proxy\_instance](#output\_proxy\_instance) | Information about the proxy instance. |
| <a name="output_registry_bucket"></a> [registry\_bucket](#output\_registry\_bucket) | The AWS S3 bucket for the registry and IAM credentials required to access it. |
| <a name="output_registry_instance"></a> [registry\_instance](#output\_registry\_instance) | Information about the registry instance. |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | Information about the provisioned VPC and its networks. |
<!-- END_ROOT_TF_DOCS -->

## VPC Submodule Documentation

<!-- BEGIN_VPC_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 3.70.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.70.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [aws_default_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/default_route_table) | resource |
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/default_security_group) | resource |
| [aws_eip.proxy](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/eip) | resource |
| [aws_instance.bastion](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/instance) | resource |
| [aws_instance.proxy](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/instance) | resource |
| [aws_internet_gateway.default](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/internet_gateway) | resource |
| [aws_route53_record.proxy](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/route53_record) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/route_table_association) | resource |
| [aws_subnet.nat](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/subnet) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/subnet) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/vpc) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | The AMI to use for the proxy and bastion instances. | `string` | n/a | yes |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | The availability zones to create subnets for. | `list(string)` | n/a | yes |
| <a name="input_bastion_flavor"></a> [bastion\_flavor](#input\_bastion\_flavor) | The instance type to use for the isolated bastion host. | `string` | `"t3.small"` | no |
| <a name="input_bastion_hostname"></a> [bastion\_hostname](#input\_bastion\_hostname) | The hostname to use when building the bastion instance. | `string` | `"bastion"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | The full name of the domain, which should be within one of your existing Route53 Hosted Zones, in which to create DNS records for the proxy. | `string` | n/a | yes |
| <a name="input_hosted_zone"></a> [hosted\_zone](#input\_hosted\_zone) | The Route53 Hosted Zone ID which contains the domain for creating proxy records. | `string` | n/a | yes |
| <a name="input_instance_password"></a> [instance\_password](#input\_instance\_password) | The password to set for the ec2-user on the proxy and bastion instances. | `string` | `""` | no |
| <a name="input_proxy_flavor"></a> [proxy\_flavor](#input\_proxy\_flavor) | The instance type to use for the proxy instance. | `string` | `"t3.small"` | no |
| <a name="input_proxy_hostname"></a> [proxy\_hostname](#input\_proxy\_hostname) | The hostname to use when building the proxy instance and creating Route 53 records for it. | `string` | `"proxy"` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | The SSH public key to use for the proxy and bastion instances - must already exist as an aws\_key\_pair! | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR-notation subnet for the entire VPC. | `string` | `"10.0.0.0/16"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_instance"></a> [bastion\_instance](#output\_bastion\_instance) | Information about the bastion instance. |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | The IDs of the subnets that route through the proxy. |
| <a name="output_proxy_instance"></a> [proxy\_instance](#output\_proxy\_instance) | Information about the proxy instance. |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | The IDs of the subnets that route through the IGW. |
<!-- END_VPC_TF_DOCS -->

## Registry Submodule Documentation

<!-- BEGIN_REGISTRY_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 3.70.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.70.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [aws_eip.registry](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/eip) | resource |
| [aws_iam_access_key.registry](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/iam_access_key) | resource |
| [aws_iam_policy.registry](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/iam_policy) | resource |
| [aws_iam_user.registry](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/iam_user) | resource |
| [aws_iam_user_policy_attachment.registry](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/iam_user_policy_attachment) | resource |
| [aws_instance.registry](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/instance) | resource |
| [aws_route53_record.registry](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/route53_record) | resource |
| [aws_s3_bucket.registry](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.registry](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_security_group.registry](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/resources/security_group) | resource |
| [aws_subnet.registry](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/data-sources/subnet) | data source |
| [aws_vpc.disco](https://registry.terraform.io/providers/hashicorp/aws/3.70.0/docs/data-sources/vpc) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | The ID of the AMI that should be used for the registry. | `string` | n/a | yes |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | The availability zone into which the registry instance should be placed - should align with the subnet's zone. | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | The full name of the domain, which should be within one of your existing Route53 Hosted Zones, in which to create DNS records for the registry. | `string` | n/a | yes |
| <a name="input_flavor"></a> [flavor](#input\_flavor) | The instance type to use for the registry instance. | `string` | `"t3.large"` | no |
| <a name="input_hosted_zone"></a> [hosted\_zone](#input\_hosted\_zone) | The Route53 Hosted Zone ID which contains the domain for creating registry records. | `string` | n/a | yes |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | The hostname to use when building the instance and creating Route 53 records for it. | `string` | `"registry"` | no |
| <a name="input_instance_password"></a> [instance\_password](#input\_instance\_password) | The password to set for the ec2-user on the registry instance. | `string` | `""` | no |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | The SSH public key to use for the proxy instance - must already exist as an aws\_key\_pair! | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the existing VPC subnet into which the instance should associate its default interface. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_registry_instance"></a> [registry\_instance](#output\_registry\_instance) | Information about the registry instance. |
| <a name="output_s3_bucket"></a> [s3\_bucket](#output\_s3\_bucket) | The AWS S3 bucket and IAM credentials required to access it. |
<!-- END_REGISTRY_TF_DOCS -->
