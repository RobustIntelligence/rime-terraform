terraform {
  required_version = "> 0.14, < 2.0.0"
  // Adds `optional` as a type constraint for variable declations.
  // This feature was added experimentally in 0.14.0 (2020-12-02):
  //   https://github.com/hashicorp/terraform/releases/tag/v0.14.0
  // This feature became non-experimental in 1.3.0 (21-09-2022):
  //   https://github.com/hashicorp/terraform/releases/tag/v1.3.0
  experiments      = [module_variable_optional_attrs]

  required_providers {
    helm = {
      source = "hashicorp/helm"
      # Note: Do not use 2.0.0 or 2.0.1 - these versions are buggy.
      # See: https://github.com/hashicorp/terraform-provider-helm/issues/662
      version = "> 2.1.0, < 3.0.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.0.0"
    }
  }
}
