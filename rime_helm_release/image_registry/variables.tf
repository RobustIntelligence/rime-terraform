variable "cloud_platform_config" {
  description = "A configuration that is specific to the cloud platform being used"
  type = object({
    platform_type = string
    // TODO(11974): make this optional once we switch to TF >= 1.3.0.
    aws_config = object({})
    // TODO(11974): make this optional once we switch to TF >= 1.3.0.
    gcp_config = object({
      location      = string
      project       = string
      node_sa_email = string
    })
  })
  validation {
    condition = (
      (
        var.cloud_platform_config.platform_type == "aws" && (
          var.cloud_platform_config.aws_config != null &&
          var.cloud_platform_config.gcp_config == null
        )
        ) || (
        var.cloud_platform_config.platform_type == "gcp" && (
          var.cloud_platform_config.aws_config == null &&
          var.cloud_platform_config.gcp_config != null
        )
      )
    )
    error_message = "you must specify a cloud platform type in {'aws', 'gcp'} and only its accompanying parameters"
  }
}

variable "image_registry_config" {
  description = <<EOT
  The configuration for the RIME Image Registry service, which manages custom images
  for running RIME stress tests with different Python model requirements:
    * enable:                       whether or not to enable the RIME Image Registry service.
    * repo_base_name:               the base name used for all repositories created
                                    and managed by the RIME Image Registry service.
  EOT
  type = object({
    enable         = bool
    repo_base_name = string
  })
  default = {
    enable         = true
    repo_base_name = "rime-managed-images"
  }
  # See https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html
  # for repository naming rules.
  validation {
    condition = (
      !var.image_registry_config.enable ||
      can(regex("^[a-z][a-z0-9]*(?:[/_-][a-z0-9]+)*$", var.image_registry_config.repo_base_name))
    )
    error_message = "The repository base name must be 1 or more lowercase alphanumeric words separated by a '-', '_', or '/' where the first character is a letter."
  }
}

variable "namespace" {
  description = "Namespace where the RIME Helm chart is to be installed."
  type        = string
}

variable "oidc_provider_url" {
  description = "URL to the OIDC provider for IAM assumable roles used by K8s."
  type        = string
}

variable "resource_name_suffix" {
  description = "A suffix to name the IAM policy and role with."
  type        = string
  # This module requires that these conditions are met.
  # The validation conditions should match the one in the outer most level where resource_name_suffix is first passed as input.
  # Redundant validation is added here as a safeguard for when the outer most resource_name_suffix conidtion is editted without updating this condition.
  # The conditions are required because resource_name_suffix is included in the blob-store S3 bucket name, which has a limit on length and what characters can be included.
  validation {
    condition     = length(var.resource_name_suffix) <= 25 && can(regex("^[a-z0-9.-]+$", var.resource_name_suffix))
    error_message = "Must not be longer than 25 characters and must contain only letters, numbers, dots (.), and hyphens (-)."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
}
