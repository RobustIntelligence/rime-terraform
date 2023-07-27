
variable "gcp_config" {
  description = "A configuration containing parameters specific to GCP"
  type = object({
    location = string
    project  = string
    // TODO: make into a list of strings called repo_reader_sa_emails
    node_sa_email = string
  })
}

variable "namespace" {
  description = "Namespace where the RIME Helm chart is to be installed."
  type        = string
}

variable "repo_base_name" {
  description = "Base name used for the repository created and managed by the RIME Image Registry service. Will also be joined with namespace and resource suffix."
  type        = string
  // See https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html
  // for repository naming rules.
  validation {
    condition     = can(regex("^[a-z][a-z0-9]*(?:[/_-][a-z0-9]+)*$", var.repo_base_name))
    error_message = "The repository base name must be 1 or more lowercase alphanumeric words separated by a '-', '_', or '/' where the first character is a letter."
  }
  default = "rime-managed-images"
}

variable "resource_name_suffix" {
  description = "A suffix to name the IAM policy and role with."
  type        = string
  # This module requires that these conditions are met.
  # The validation conditions should match the one in the outer most level where resource_name_suffix is first passed as input.
  # Redundant validation is added here as a safeguard for when the outer most resource_name_suffix conidtion is editted without updating this condition.
  # The conditions are required because resource_name_suffix is included in the blob-store S3 bucket name, which has a limit on length and what characters can be included.
  validation {
    condition     = length(var.resource_name_suffix) <= 25 && can(regex("^[a-z0-9-]+$", var.resource_name_suffix))
    error_message = "Must not be longer than 25 characters and must contain only letters, numbers, and hyphens (-)."
  }
}
