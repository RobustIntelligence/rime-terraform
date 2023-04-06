locals {
  is_namespace_default = (var.namespace == "default")
  tags                 = join(",", [for key, value in var.tags : "${key}=${value}"])
}

resource "kubernetes_namespace" "namespace" {
  // Create for each non-default namespaces.
  count = local.is_namespace_default || !var.manage_namespace ? 0 : 1

  metadata {
    name = var.namespace
    labels = {
      name = var.namespace
    }
  }
}

// Create secret used by the RIME control plane to initialize the first admin user.
resource "kubernetes_secret" "admin-secrets" {
  count = var.manage_namespace ? 1 : 0
  metadata {
    name      = "rime-admin-secret"
    namespace = var.namespace
  }

  data = {
    admin-username = var.admin_username
    admin-password = var.admin_password
  }
  depends_on = [kubernetes_namespace.namespace]
}

// Create blob store bucket and IAM permissions to upload to the blob store.
module "blob_store" {
  source = "./blob_store"

  count = var.enable_blob_store ? 1 : 0

  namespace            = var.namespace
  oidc_provider_url    = var.oidc_provider_url
  resource_name_suffix = var.resource_name_suffix
  force_destroy        = var.force_destroy
  tags                 = var.tags
}

// Create permissions to push and manage images in ECR
module "image_registry" {
  source = "./image_registry"

  count = var.image_registry_config.enable ? 1 : 0

  cloud_platform_config = var.cloud_platform_config

  namespace             = var.namespace
  oidc_provider_url     = var.oidc_provider_url
  image_registry_config = var.image_registry_config
  resource_name_suffix  = var.resource_name_suffix
  tags                  = var.tags
}

// Create secret "rimecreds" in each namespace if we created the namespace
resource "kubernetes_secret" "docker-secrets" {
  count = var.manage_namespace ? 1 : 0
  metadata {
    name      = var.docker_secret_name
    namespace = var.namespace
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
  depends_on = [kubernetes_namespace.namespace]
}

# The YAML file created by instantiating `values_tmpl.yaml`.
resource "local_file" "helm_values" {
  content = templatefile("${path.module}/values_tmpl.yaml", {
    acm_cert_arn = var.acm_cert_arn

    blob_store_config = {
      enable         = var.enable_blob_store
      s3_bucket_name = var.enable_blob_store ? module.blob_store[0].blob_store_bucket_name : ""
      role_arn       = var.enable_blob_store ? module.blob_store[0].blob_store_role_arn : ""
    }

    docker_image_names    = var.docker_image_names
    docker_secret_name    = var.docker_secret_name
    docker_registry       = var.docker_registry
    domain                = var.domain == "" ? "placeholder" : var.domain
    enable_api_key_auth   = var.enable_api_key_auth
    disable_vault_tls     = var.disable_vault_tls
    enable_mongo_tls      = var.enable_mongo_tls
    enable_redis_tls      = var.enable_redis_tls
    enable_rest_tls       = var.enable_rest_tls
    enable_grpc_tls       = var.enable_grpc_tls
    enable_crossplane_tls = var.enable_crossplane_tls
    enable_cert_manager   = var.enable_cert_manager
    enable_autorotate_tls = var.enable_autorotate_tls
    external_vault        = var.external_vault

    image_registry_config = var.image_registry_config.enable ? module.image_registry[0].image_registry_config : null

    lb_tags                      = length(local.tags) > 0 ? "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags: \"${local.tags}\"" : ""
    lb_type                      = var.internal_lbs ? "internal" : "internet-facing"
    mongo_db_size                = var.mongo_db_size
    storage_class_name           = var.storage_class_name != "" ? var.storage_class_name : "default"
    namespace                    = var.namespace
    pull_policy                  = var.rime_version == "latest" ? "Always" : "IfNotPresent"
    rime_license                 = var.rime_license
    verbose                      = var.verbose
    version                      = var.rime_version
    ip_allowlist                 = var.ip_allowlist
    separate_model_testing_group = var.separate_model_testing_group
    release_name                 = var.release_name
    datadog_tag_pod_annotation   = var.datadog_tag_pod_annotation
  })
  filename = format("%s/values_%s.yaml", length(var.helm_values_output_dir) == 0 ? path.cwd : var.helm_values_output_dir, var.namespace)
}

# The release of the RIME Helm chart in a given k8s namespace.
resource "helm_release" "rime" {
  count = var.create_managed_helm_release ? 1 : 0

  # Chart information.
  repository = var.rime_repository
  chart      = "rime"
  version    = var.rime_version

  name              = var.release_name
  namespace         = var.namespace
  create_namespace  = !local.is_namespace_default
  dependency_update = true
  force_update      = false
  lint              = true
  recreate_pods     = false
  wait              = false

  values = [
    local_file.helm_values.content,
    length(var.override_values_file_path) > 0 ? file(var.override_values_file_path) : "",
  ]
  depends_on = [kubernetes_namespace.namespace]
}
