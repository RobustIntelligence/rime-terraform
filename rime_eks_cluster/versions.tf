terraform {
  required_version = "> 0.14, < 2.0.0"

  required_providers {
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0, < 4.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1, < 3.0.0"
    }
  }
}
