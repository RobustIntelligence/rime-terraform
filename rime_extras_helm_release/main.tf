locals {
  output_dir = length(var.helm_values_output_dir) == 0 ? path.cwd : var.helm_values_output_dir
}

# The YAML file created by instantiating `values_tmpl.yaml`.
resource "local_file" "rime_extras" {
  content = templatefile("${path.module}/values_tmpl.yaml", {
    datadog_api_key          = var.datadog_api_key
    datadog_rime_version_tag = var.rime_version
    datadog_user_tag         = var.rime_user
    docker_registry          = var.docker_registry
    docker_secret_name       = var.docker_secret_name
    install_datadog          = var.install_datadog
    install_velero           = var.install_velero
    velero_s3_bucket_name    = var.install_velero ? aws_s3_bucket.velero_s3_bucket[0].bucket : ""
    velero_s3_region         = var.install_velero ? aws_s3_bucket.velero_s3_bucket[0].region : ""
    velero_s3_role_arn       = var.install_velero ? module.iam_assumable_role_with_oidc_for_velero[0].this_iam_role_arn : ""
    velero_backup_ttl        = var.velero_backup_ttl
    velero_backup_schedule   = var.velero_backup_schedule
  })
  filename = format("%s/rime_extras_values.yaml", local.output_dir)
}

# The release of the RIME kube extras Helm chart for rime extra resources needed for our service to function
resource "helm_release" "rime_extras" {
  count = var.create_managed_helm_release ? 1 : 0

  # Chart information.
  repository = var.rime_repository
  chart      = "rime-extras"
  version    = var.rime_version

  name              = "rime-extras"
  namespace         = "rime-extras"
  dependency_update = true
  force_update      = false
  lint              = true
  recreate_pods     = false
  wait              = false

  values = [
    local_file.rime_extras.content
  ]

  depends_on = [
    kubernetes_namespace.rime_extras
  ]
}

// Create namespace "rime-extras" if we are managing the helm release
resource "kubernetes_namespace" "rime_extras" {
  count = var.manage_namespace ? 1 : 0
  metadata {
    name = "rime-extras"
    labels = {
      name = "rime-extras"
    }
  }
}

// Create secret "rimecreds" in each namespace if we are managing the helm release
resource "kubernetes_secret" "docker-secrets" {
  count = var.manage_namespace ? 1 : 0
  metadata {
    name      = var.docker_secret_name
    namespace = "rime-extras"
  }
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        for creds in var.docker_credentials :
        creds["docker-server"] => merge(
          { for k, v in creds : k => v if v != null },
          { auth = base64encode("${creds["docker-username"]}:${creds["docker-password"]}") },
        )
      }
    })
  }
  type       = "kubernetes.io/dockerconfigjson"
  depends_on = [kubernetes_namespace.rime_extras]
}
