output "image_registry_config" {
  value = {
    registry_type                = local.registry_type
    allow_external_custom_images = true
    ecr_config                   = local.is_ecr ? module.ecr[0].ecr_config : null
    managed-image-repo-builder-annotation = (
      local.is_ecr ? module.ecr[0].managed-image-repo-builder-annotation : ""
    )
    managed-image-repo-admin-annotation = (
      local.is_ecr ? module.ecr[0].managed-image-repo-admin-annotation : ""
    )
  }
}
