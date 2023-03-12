terraform {
  required_version = "> 0.14, < 2.0.0"

  required_providers {
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }
}
