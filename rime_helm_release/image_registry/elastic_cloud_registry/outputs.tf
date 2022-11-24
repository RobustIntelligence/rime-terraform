output "ecr_config" {
  value = {
    registry_id       = data.aws_caller_identity.current.account_id
    repository_prefix = local.unique_repository_prefix
  }
}

output "managed-image-repo-admin-annotation" {
  value = "eks.amazonaws.com/role-arn: \"${module.iam_assumable_role_with_oidc_for_ecr_repo_management.this_iam_role_arn}\""
}

output "managed-image-repo-builder-annotation" {
  value = "eks.amazonaws.com/role-arn: \"${module.iam_assumable_role_with_oidc_for_ecr_image_builder.this_iam_role_arn}\""
}
