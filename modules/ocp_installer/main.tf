terraform {
  required_version = ">= 1.4.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.58.0"
    }
  }
}
# The permissions required for OpenShift installation are already pretty
#  high, so this is expected to be a problem. We should still see about
#  what we can do to scope these down a bit more later.
#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "ocp_installer" {
  name = "${var.domain}-ocp-installer"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "RequiredEC2PermissionsForInstallation",
        "Effect" : "Allow",
        "Action" : [
          "ec2:TerminateInstances",
          "ec2:RunInstances",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:ReleaseAddress",
          "ec2:Modify*",
          "ec2:GetEbsDefaultKmsKeyId",
          "ec2:Disassociate*",
          "ec2:DescribeVpcs",
          "ec2:Describe*",
          "ec2:Deregister*",
          "ec2:DeleteTags",
          "ec2:DeleteSnapshot",
          "ec2:DeleteSecurityGroup",
          "ec2:CreateVolume",
          "ec2:CreateTags",
          "ec2:CreateSecurityGroup",
          "ec2:CreateNetworkInterface",
          "ec2:CopyImage",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AttachNetworkInterface",
          "ec2:AssociateAddress",
          "ec2:AllocateAddress"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "RequiredPermissionsForCreatingNetworkResourcesDuringInstallation",
        "Effect" : "Allow",
        "Action" : [
          "ec2:ModifyVpcAttribute",
          "ec2:ModifySubnetAttribute",
          "ec2:CreateVpcEndpoint",
          "ec2:CreateVpc",
          "ec2:CreateSubnet",
          "ec2:CreateRouteTable",
          "ec2:CreateRoute",
          "ec2:CreateNatGateway",
          "ec2:CreateInternetGateway",
          "ec2:CreateDhcpOptions",
          "ec2:AttachInternetGateway",
          "ec2:AssociateRouteTable",
          "ec2:AssociateDhcpOptions"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "RequiredElasticloadbalancingPermissionsForInstallation",
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeInstanceHealth",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:DeleteL*",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:CreateLoadBalancerListeners",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:ConfigureHealthCheck",
          "elasticloadbalancing:AttachLoadBalancerToSubnets",
          "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
          "elasticloadbalancing:AddTags"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "RequiredIAMPermissionsForInstallation",
        "Effect" : "Allow",
        "Action" : [
          "iam:TagRole",
          "iam:SimulatePrincipalPolicy",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:PutRolePolicy",
          "iam:PassRole",
          "iam:List*",
          "iam:GetUser",
          "iam:GetRolePolicy",
          "iam:GetRole",
          "iam:GetInstanceProfile",
          "iam:DeleteRolePolicy",
          "iam:DeleteRole",
          "iam:DeleteInstanceProfile",
          "iam:CreateRole",
          "iam:CreateInstanceProfile",
          "iam:AddRoleToInstanceProfile"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "RequiredRoute53PermissionsForInstallation",
        "Effect" : "Allow",
        "Action" : [
          "route53:UpdateHostedZoneComment",
          "route53:ListTagsForResource",
          "route53:ListResourceRecordSets",
          "route53:ListHostedZonesByName",
          "route53:ListHostedZones",
          "route53:GetHostedZone",
          "route53:GetDNSSEC",
          "route53:GetChange",
          "route53:DeleteHostedZone",
          "route53:CreateHostedZone",
          "route53:ChangeTagsForResource",
          "route53:ChangeResourceRecordSets"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "RequiredS3PermissionsForInstallation",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutEncryptionConfiguration",
          "s3:PutBucketTagging",
          "s3:PutBucketAcl",
          "s3:ListBucket",
          "s3:GetReplicationConfiguration",
          "s3:GetLifecycleConfiguration",
          "s3:GetEncryptionConfiguration",
          "s3:GetBucketWebsite",
          "s3:GetBucketVersioning",
          "s3:GetBucketTagging",
          "s3:GetBucketRequestPayment",
          "s3:GetBucketReplication",
          "s3:GetBucketObjectLockConfiguration",
          "s3:GetBucketLogging",
          "s3:GetBucketLocation",
          "s3:GetBucket*",
          "s3:GetAccelerateConfiguration",
          "s3:DeleteBucket",
          "s3:CreateBucket"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "S3PermissionsThatClusterOperatorsRequire",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObjectTagging",
          "s3:PutObjectAcl",
          "s3:PutObject",
          "s3:GetObjectVersion",
          "s3:GetObjectTagging",
          "s3:GetObjectAcl",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "RequiredPermissionsToDeleteBaseClusterResources",
        "Effect" : "Allow",
        "Action" : [
          "tag:*",
          "s3:ListBucketVersions",
          "s3:DeleteObject",
          "iam:ListUserPolicies",
          "iam:ListRolePolicies",
          "iam:ListInstanceProfiles",
          "iam:DeleteUser",
          "iam:DeleteAccessKey",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DeleteTargetGroup",
          "ec2:DeleteVolume",
          "ec2:DeleteNetworkInterface",
          "autoscaling:DescribeAutoScalingGroups"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "RequiredPermissionsToDeleteNetworkResources",
        "Effect" : "Allow",
        "Action" : [
          "ec2:ReplaceRouteTableAssociation",
          "ec2:Disassociate*",
          "ec2:DetachInternetGateway",
          "ec2:DeleteVpcEndpoints",
          "ec2:DeleteVpc",
          "ec2:DeleteSubnet",
          "ec2:DeleteRouteTable",
          "ec2:DeleteRoute",
          "ec2:DeleteNatGateway",
          "ec2:DeleteInternetGateway",
          "ec2:DeleteDhcpOptions"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AdditionalIamAndS3PermissionsToCreateManifests",
        "Effect" : "Allow",
        "Action" : [
          "servicequotas:List*",
          "s3:PutLifecycleConfiguration",
          "s3:PutBucketPublicAccessBlock",
          "s3:ListBucketMultipartUploads",
          "s3:HeadBucket",
          "s3:GetBucketPublicAccessBlock",
          "s3:AbortMultipartUpload",
          "iam:TagUser",
          "iam:PutUserPolicy",
          "iam:ListAccessKeys",
          "iam:GetUserPolicy",
          "iam:DeleteUserPolicy",
          "iam:DeleteUser",
          "iam:DeleteAccessKey",
          "iam:CreateUser",
          "iam:CreateAccessKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "S3PermissionsRequiredForTowerDeploy",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListMultipartUploadParts",
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowToRunAnsibleEdgeOnOpenShiftWorkshop",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DeleteKeyPair",
          "ec2:CreateKeyPair"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# - This is deliberate
#tfsec:ignore:aws-iam-no-user-attached-policies
resource "aws_iam_user" "ocp_installer" {
  name = "${var.domain}-ocp-installer"
}

resource "aws_iam_user_policy_attachment" "ocp_installer" {
  user       = aws_iam_user.ocp_installer.name
  policy_arn = aws_iam_policy.ocp_installer.arn
}

resource "aws_iam_access_key" "ocp_installer" {
  user = aws_iam_user.ocp_installer.name
}
