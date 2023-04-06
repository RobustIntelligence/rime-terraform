locals {
  is_ecr = var.cloud_platform_config.platform_type == "aws"
  is_gar = var.cloud_platform_config.platform_type == "gcp"
  registry_type = (
    local.is_ecr ? "ecr" : (
      local.is_gar ? "gar" : null
    )
  )
}

module "ecr" {
  source = "./elastic_cloud_registry"
  count  = local.is_ecr ? 1 : 0

  namespace            = var.namespace
  oidc_provider_url    = var.oidc_provider_url
  repository_prefix    = var.image_registry_config.repo_base_name
  resource_name_suffix = var.resource_name_suffix
  tags                 = var.tags
}
