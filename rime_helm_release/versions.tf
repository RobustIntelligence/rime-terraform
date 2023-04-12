terraform {
  required_version = "> 0.14, < 2.0.0"
  // DO NOT USE experiment module_variable_optional_attrs.  It is not compatible
  // with future versions of terraform >= 1.3.0
  //
  // TODO(11974): allow for optional() variable declarations by requiring
  // a version >= 1.3.0.

  required_providers {
    helm = {
      source = "hashicorp/helm"
      # Note: Do not use 2.0.0 or 2.0.1 - these versions are buggy.
      # See: https://github.com/hashicorp/terraform-provider-helm/issues/662
      version = "> 2.1.0, < 3.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1, < 3.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0.0"
    }
  }
}
