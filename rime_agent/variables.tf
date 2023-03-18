variable "namespace" {
  description = "The k8s namespace to install the rime-agent into"
  type        = string
}

variable "custom_values_file_path" {
  description = <<EOT
  Optional file path to custom values file for the rime-agent helm release.
  Values produced by the terraform module will take precedence over these values.
  EOT
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
  default     = {}
}

variable "rime_repository" {
  description = "Repository URL where to locate the requested RIME chart for the give `rime_version`."
  type        = string
}

variable "rime_version" {
  description = "The version of the RIME software to be installed."
  type        = string
}

variable "resource_name_suffix" {
  description = <<EOT
  A suffix to use with the names of resources created by this module.
  EOT
  type        = string
  # TODO(andrew): Do we need validation for s3_blob_store usage?
  # These conditions should match the conditions of modules that rely on this variable.
  # Currently the modules that rely on these conditions are:
  #   - rime_helm_release/s3_blob_store (resource_name_suffix is included in the blob-store S3 bucket name, which has a limit on length and what characters can be included)
  #validation {
  #  condition = (
  #  length(var.resource_name_suffix) <= 25 &&
  # can(regex("^[a-z0-9.-]+$", var.resource_name_suffix))
  # )
  # error_message = "Must not be longer than 25 characters and must contain only letters, numbers, dots (.), and hyphens (-)."
  # }
}

variable "s3_authorized_bucket_path_arns" {
  description = <<EOT
  A list of all S3 bucket path arns of which RIME will be granted access to.
  Each path must be of the form:
      arn:aws:s3:::<BUCKET>/sub/path
  where <BUCKET> is the name of the S3 bucket and `sub/path` comprises
  some path within the bucket. You can also use wildcards '?' or '*' within
  the arn specification (e.g. 'arn:aws:s3:::datasets/*').
  EOT
  type        = list(string)
}

variable "create_managed_helm_release" {
  description = <<EOT
  Whether to deploy the RIME Agent Helm chart onto the provisioned infrastructure managed by Terraform.
  Changing the state of this variable will either install/uninstall the RIME deployment
  once the change is applied in Terraform. If you want to install the RIME package manually,
  set this to false and use both the custom values file and the terraform generated values YAML file to deploy the release
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
  type        = list(map(string))
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

variable "docker_secret_name" {
  description = "The name of the Kubernetes secret used to pull the Docker image for RIME's backend services."
  type        = string
  default     = "rimecreds"
}

variable "manage_namespace" {
  description = <<EOT
  Whether or not to manage the namespace we are installing into.
  This will create the namespace(if applicable), setup docker credentials as a
  kubernetes secret etc. Turn this flag off if you have trouble connecting to
  k8s from your terraform environment.
  EOT
  type        = bool
  default     = true
}

variable "rime_docker_agent_image" {
  description = "The name of the Docker image for the RIME agent, not including a tag."
  type        = string
  default     = "robustintelligencehq/rime-agent"
}

variable "rime_docker_default_engine_image" {
  description = "The name of the Docker image used as the default for the RIME engine, not including a tag."
  type        = string
  default     = "robustintelligencehq/rime-testing-engine-dev"
}

variable "model_test_job_config_map" {
  description = "The name of the configmap to create that will be used to inject env variables into model test jobs"
  type        = string
  default     = ""
}

variable "docker_registry" {
  description = "The name of the Docker registry that holds the chart images"
  type        = string
  default     = "docker.io"
}

variable "oidc_provider_url" {
  description = "URL to the OIDC provider for IAM assumable roles used by K8s."
  type        = string
}

variable "cp_release_name" {
  description = "Name of the control plane helm release to determine addresses."
  type        = string
  default     = "rime"
}

variable "cp_namespace" {
  description = "Namespace where the control plane helm chart is installed. Used to determine addresses."
  type        = string
  default     = "default"
}

variable "log_archival_config" {
  description = <<EOT
  The configuration for RIME job log archival. This requires permissions to write to an s3 bucket.
    * enable:                 whether or not to enable log archival.
    * bucket_name:            the name of the bucket to store logs in.
  EOT
  type = object({
    enable      = bool
    bucket_name = string
  })
  default = {
    enable      = false
    bucket_name = ""
  }
}

variable "datadog_tag_pod_annotation" {
  description = "Pod annotation for Datadog tagging. Must be a string in valid JSON format, e.g. {\"tag\": \"val\"}."
  type        = string
  default     = ""
}

variable "enable_crossplane_tls" {
  description = "enable tls for crossplane"
  type        = bool
  default     = true
}

variable "enable_cert_manager" {
  description = "enable deployment of cert-manager"
  type        = bool
  default     = true
}
