terraform {
  required_version = "~> 1.2.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.7"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }

  }

  # backend "s3" {}

}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}