terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.bucket-region
  default_tags {
    tags = {
      project = var.project-name
    }
  }
}
