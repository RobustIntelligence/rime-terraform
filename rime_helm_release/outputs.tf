output "blob_store_bucket_arn" {
  value = var.enable_blob_store ? module.blob_store[0].blob_store_bucket_arn : ""
}

output "blob_store_bucket_name" {
  value = var.enable_blob_store ? module.blob_store[0].blob_store_bucket_name : ""
}
