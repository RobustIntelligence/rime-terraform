output "gar_config" {
  value = {
    location   = var.gcp_config.location
    project    = var.gcp_config.project
    repository = local.unique_repository_name
  }
}

output "managed-image-repo-admin-annotation" {
  value = "iam.gke.io/gcp-service-account: \"${google_service_account.managed-image-repo-admin.email}\""
}

output "managed-image-repo-builder-annotation" {
  value = "iam.gke.io/gcp-service-account: \"${google_service_account.image-pusher-sa.email}\""
}
