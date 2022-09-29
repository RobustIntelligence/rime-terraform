variable "admin_username" {
  description = "The initial admin username for your installation. Must be a valid email."
  type        = string
}

variable "admin_password" {
  description = "The initial admin password for your installation"
  type        = string
}

variable "create_managed_helm_release" {
  description = <<EOT
  Whether to deploy a RIME Helm chart onto the provisioned infrastructure managed by Terraform.
  Changing the state of this variable will either install/uninstall the RIME deployment
  once the change is applied in Terraform. If you want to install the RIME package manually,
  set this to false and use the generated values YAML file to deploy the release
  on the provisioned infrastructure.
  EOT
  type        = bool
  default     = false
}

variable "docker_credentials" {
  description = <<EOT
  Credentials to pass into docker image pull secrets. Has creds for all registries. Must be structured like so:
  [{
    docker-server= "",
    docker-username="",
    docker-password="",
    docker-email=""
  }]
  EOT
  type = list(map(string))
}

variable "docker_registry" {
  description = "The name of the docker registry holding all of the chart images"
  type        = string
  default     = "docker.io"
}

variable "docker_secret_name" {
  description = "The name of the Kubernetes secret used to pull the Docker image for RIME's backend services."
  type        = string
  default     = "rimecreds"
}

variable "domain" {
  description = "The domain to use for all exposed rime services."
  type        = string
}

variable "enable_api_key_auth" {
  description = "Use api keys to authenticate api requests"
  type        = bool
  default     = true
}

variable "enable_blob_store" {
  description = "Whether to use blob store for the cluster."
  type        = bool
  default     = true
}

variable "enable_image_registry" {
  description = "Whether to use managed image registry for the cluster."
  type = bool
  default = true
}

variable "helm_values_output_dir" {
  description = <<EOT
  The directory where to write the generated values YAML file used to configure the Helm release.
  For the give namespace `k8s_namespace`, a Helm chart "$helm_values_output_dir/values_$namespace.yaml"
  will be created.
  EOT
  type        = string
  default     = ""
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
    enable            = bool
    repo_base_name    = string
  })
  default = {
    enable            = true
    repo_base_name    = "rime-managed-images"
  }
  # See https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html
  # for repository naming rules.
  validation {
    condition = (
      !var.image_registry_config.enable ||
      can(regex("^[a-z][a-z0-9]*(?:[/_-][a-z0-9]+)*$", var.image_registry_config.repo_base_name))
    )
    error_message = "The repository prefix must be 1 or more lowercase alphanumeric words separated by a '-', '_', or '/' where the first character is a letter."
  }
}

variable "namespace" {
  description = "Namespace where the RIME Helm chart is to be installed."
  type        = string
}

variable "rime_license" {
  description = "Json Web Token containing Robust Intelligence license information."
  type        = string
}

variable "rime_repository" {
  description = "Repository URL where to locate the requested RIME chart for the given `rime_version`."
  type        = string
}

// TODO(blaine): should we peg the TF module version & the Helm chart version since they
// interact through the values template?
variable "rime_version" {
  description = "The version of the RIME software to be installed."
  type        = string
}

variable "mongo_db_size" {
  description = "MongoDb volume size"
  type        = string
  default     = "32Gi"
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
}

// TODO(chris): change to verbosity level instead of boolean
variable "verbose" {
  description = "Whether to use verbose mode for RIME application services."
  type        = bool
  default     = false
}

variable "acm_cert_arn" {
  description = "ARN for the acm cert to validate our domain."
  type        = string
}

variable "user_pilot_flow" {
  description = "A unique flow ID shown when choosing the option of \"Trigger manually\" on userpilot dashboard"
  type        = string
}

variable "internal_lbs" {
  description = "Whether or not the load balancers should be spun up as internal."
  type        = bool
  default     = false
}

variable "ip_allowlist" {
  # Note: external client IP's are preserved by load balancer. You may also want to include the external IP for the
  # cluster on the allowlist if OIDC is being used, since OIDC will make a callback to the auth-server using that IP.
  description = "CIDR's to add to allowlist for all ingresses. If not specified, all IP's are allowed."
  type        = list(string)
  default     = []
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

variable "separate_model_testing_group" {
  description = "Whether to force model testing jobs to run on dedicated model-testing nodes, using NodeSelectors"
  type        = bool
  default     = true
}

variable "storage_class_name" {
  description = "Name of storage class to use for persistent volumes"
  type        = string
  default     = "expandable-storage"
}

variable "release_name" {
 description = "helm release name"
   type        = string
   default     = "rime"
 }
