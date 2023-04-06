terraform {
  required_version = "> 0.14, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.75.0"
    }
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
