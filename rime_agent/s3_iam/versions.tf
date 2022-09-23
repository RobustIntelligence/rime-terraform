terraform {
  required_version = "> 0.14, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0, < 4.0.0"
    }
  }
}
