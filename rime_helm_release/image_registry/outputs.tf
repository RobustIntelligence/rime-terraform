output "ecr_repo_manager_role_arn" {
  value = module.iam_assumable_role_with_oidc_for_ecr_repo_management.this_iam_role_arn
}

output "ecr_image_builder_role_arn" {
  value = module.iam_assumable_role_with_oidc_for_ecr_image_builder.this_iam_role_arn
}

output "ecr_registry_id" {
  value = data.aws_caller_identity.current.account_id
}

output "unique_repository_prefix" {
  value = local.unique_repository_prefix
}
