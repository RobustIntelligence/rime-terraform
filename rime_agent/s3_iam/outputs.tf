output "s3_reader_role_arn" {
  value = module.iam_assumable_role_with_oidc_for_s3_access.this_iam_role_arn
}
