# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {

  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }
  required_version = "~> 1.4"

    backend "s3" {
        bucket         = "temp-terraform-state-bucket"
        key            = "terraform.tfstate"
        region         = "us-east-1"
        encrypt = true
    }
}






