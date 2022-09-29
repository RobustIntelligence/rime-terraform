terraform {
  required_version = "> 0.14, < 2.0.0"

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
