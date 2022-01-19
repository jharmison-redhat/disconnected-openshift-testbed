# - We're heavily restricting access to this bucket, and encrypting it will
#   only slow it down and make configuration more complex
# - Logging is unnecessarily complex for this simple environment
# - Versioning doesn't matter as blobs used by the registry will be globally
#   unique anyways, thanks to hashing
#tfsec:ignore:aws-s3-enable-bucket-encryption tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "registry" {
  force_destroy = true
  bucket        = "${var.cluster_name}-${var.cluster_domain}-registry"
  acl           = "private"
}

resource "aws_s3_bucket_public_access_block" "registry" {
  bucket = aws_s3_bucket.registry.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_policy" "registry" {
  name = "${var.cluster_name}.${var.cluster_domain}-registry"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListStorageLensConfigurations",
          "s3:ListAccessPointsForObjectLambda",
          "s3:GetAccessPoint",
          "s3:PutAccountPublicAccessBlock",
          "s3:GetAccountPublicAccessBlock",
          "s3:ListAllMyBuckets",
          "s3:ListAccessPoints",
          "s3:ListJobs",
          "s3:PutStorageLensConfiguration",
          "s3:ListMultiRegionAccessPoints",
          "s3:CreateJob"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : "${aws_s3_bucket.registry.arn}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : "${aws_s3_bucket.registry.arn}"
      }
    ]
  })
}

resource "aws_iam_user" "registry" {
  name = "${var.cluster_name}.${var.cluster_domain}-registry"
}

resource "aws_iam_user_policy_attachment" "registry" {
  user       = aws_iam_user.registry.name
  policy_arn = aws_iam_policy.registry.arn
}

resource "aws_iam_access_key" "registry" {
  user = aws_iam_user.registry.name
}
