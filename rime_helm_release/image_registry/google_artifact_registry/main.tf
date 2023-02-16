locals {
  candidate_name = "${var.repo_base_name}-${var.resource_name_suffix}-${var.namespace}"
  unique_repository_name = length(local.candidate_name) <= 63 ? local.candidate_name : (
    substr(local.candidate_name, 0, 49) + substr(md5(local.candidate_name), 0, 14)
  )
}

// The Docker repository to store all managed images within.
resource "google_artifact_registry_repository" "managed-image-repo" {
  location      = var.gcp_config.location
  project       = var.gcp_config.project
  repository_id = local.unique_repository_name
  description   = "Docker repository where generated managed images are stored."
  format        = "DOCKER"
}

// The IAM member for nodes to be able to read from the new Docker repository.
resource "google_artifact_registry_repository_iam_member" "node-repo-reader-member" {
  location   = var.gcp_config.location
  project    = var.gcp_config.project
  repository = local.unique_repository_name

  # For a list of all roles for the google artifact registry, see:
  # https://cloud.google.com/artifact-registry/docs/access-control#permissions
  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${var.gcp_config.node_sa_email}"

  depends_on = [
    google_artifact_registry_repository.managed-image-repo,
  ]
}

// The Service Account and IAM member used to manage the new Docker repository.
// We also allow this Service Account to be used by a workload identity so that
// our Kubernetes role can act as it.
resource "google_service_account" "managed-image-repo-admin" {
  project      = var.gcp_config.project
  account_id   = "managed-image-repository-admin"
  display_name = "Managed Image Repository Admin"
  description  = "The service account that can administer the repository for managed images"
}

resource "google_service_account_iam_member" "managed-image-repo-admin-workload-identity-iam" {
  service_account_id = google_service_account.managed-image-repo-admin.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_config.project}.svc.id.goog[${var.namespace}/rime-${var.namespace}-repo-manager]"

  depends_on = [
    google_service_account.managed-image-repo-admin,
  ]
}

resource "google_project_iam_custom_role" "docker-admin-role" {
  project     = var.gcp_config.project
  role_id     = "dockerAdmin"
  title       = "Artifact Registry Role for Docker Images"
  description = "The role that grants fine-grained docker permissions"
  permissions = [
    "artifactregistry.dockerimages.get",
    "artifactregistry.dockerimages.list",
  ]
}

resource "google_artifact_registry_repository_iam_member" "member" {
  location   = var.gcp_config.location
  project    = var.gcp_config.project
  repository = local.unique_repository_name

  # For a list of all roles for the google artifact registry, see:
  # https://cloud.google.com/artifact-registry/docs/access-control#permissions
  role   = "roles/artifactregistry.repoAdmin"
  member = "serviceAccount:${google_service_account.managed-image-repo-admin.email}"

  depends_on = [
    google_service_account.managed-image-repo-admin,
    google_artifact_registry_repository.managed-image-repo,
  ]
}

// The Service Account and IAM member used to push new images to the repository.
// We also allow this Service Account to be used by a workload identity so that
// our Kubernetes role can act as it.
resource "google_service_account" "image-pusher-sa" {
  project      = var.gcp_config.project
  account_id   = "rime-image-pusher-sa"
  display_name = "Managed Image Pusher Service Account"
  description  = "The service account that can build and push new images to the managed image repository."
}

resource "google_service_account_iam_member" "image-pusher-sa-workload-identity-iam" {
  service_account_id = google_service_account.image-pusher-sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_config.project}.svc.id.goog[${var.namespace}/rime-${var.namespace}-image-pusher]"

  depends_on = [
    google_service_account.image-pusher-sa,
  ]
}

resource "google_artifact_registry_repository_iam_member" "pusher-role-membership" {
  location   = var.gcp_config.location
  project    = var.gcp_config.project
  repository = local.unique_repository_name

  # For a list of all roles for the google artifact registry, see:
  # https://cloud.google.com/artifact-registry/docs/access-control#permissions
  role   = "roles/artifactregistry.writer"
  member = "serviceAccount:${google_service_account.image-pusher-sa.email}"

  depends_on = [
    google_service_account.image-pusher-sa,
    google_artifact_registry_repository.managed-image-repo,
  ]
}
