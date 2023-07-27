output "blob_store_bucket_arn" {
  value = aws_s3_bucket.s3_blob_store_bucket.arn
}

output "blob_store_role_arn" {
  value = module.iam_assumable_role_with_oidc_for_s3_blob_store.this_iam_role_arn
}

output "blob_store_bucket_name" {
  value = aws_s3_bucket.s3_blob_store_bucket.bucket
}
