data "aws_partition" "current" {}

# This policy depends on the set of S3 paths that our service needs access to
# supplied by the inputs to our terraform module.
#
# For an example of such a policy;
# see: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_condition_operators.html#Conditions_String
#
# For specification of the bucket ARNs;
# see: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_resource.html
data "aws_iam_policy_document" "eks_s3_access_policy_document" {
  # Add a policy statement per bucket-path that allows one to list objects within
  # that bucket-path.
  dynamic "statement" {
    for_each = var.s3_authorized_bucket_path_arns
    content {
      actions = [
        "s3:ListBucket",
      ]

      # The resource that we're allowing list access to is an S3 bucket (no subdirectories).
      # This regexp matches the bucket name of the form:
      #     arn:aws:s3:::${BUCKET_NAME}
      # where ${BUCKET_NAME} has no '/' separators.
      resources = [
        replace(statement.value, "/^(arn:${data.aws_partition.current.partition}:s3:::[^/]+)(?:/.*)?$/", "$1"),
      ]

      # This restricts the list access to only paths matching the given parent directory;
      # ie. if the full bucket path was 'arn:aws:s3:::${BUCKET_NAME}/foo/bar/baz/*'
      # then we want to resrict the list access to only paths that begin with '/foo/bar/baz'
      dynamic "condition" {
        # Only create this prefix if the given path includes at least 1 parent directory.
        # TODO(blaine): This is a hack to use a for_each to do a conditional.
        for_each = length(regexall("^arn:${data.aws_partition.current.partition}:s3:::[^/]+/[^/]+/.*$", statement.value)) > 0 ? ["dummy_value"] : []
        content {
          test     = "StringLike"
          variable = "s3:prefix"

          # Extract the parent directory.
          values = [
            "${dirname(replace(statement.value, "/^arn:${data.aws_partition.current.partition}:s3:::[^/]+/(.*)$/", "$1"))}/*",
          ]
        }
      }
    }
  }

  # Add a policy statement that allows one to get (read) objects in all
  # of the allowed bucket-paths.
  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = var.s3_authorized_bucket_path_arns
  }
}

resource "aws_iam_policy" "eks_s3_access_policy" {
  name = "eks_s3_access_policy_${var.resource_name_suffix}_${var.namespace}"

  policy = data.aws_iam_policy_document.eks_s3_access_policy_document.json

  tags = var.tags
}

module "iam_assumable_role_with_oidc_for_s3_access" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 3.0"

  create_role      = true
  role_name        = "eks_s3_access_${var.resource_name_suffix}_${var.namespace}"
  role_description = "Role to access s3 bucket"

  provider_url = var.oidc_provider_url

  role_policy_arns = [
    aws_iam_policy.eks_s3_access_policy.arn,
  ]

  number_of_role_policy_arns = 1

  oidc_fully_qualified_subjects = [
    "system:serviceaccount:${var.namespace}:${var.service_account_name}"
  ]

  tags = var.tags
}
