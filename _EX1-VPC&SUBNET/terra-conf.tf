terraform {
  required_version = "~> 1.2.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.7"
    }

  }

  backend "s3" {}
  # terraform init -backend-config="+bknd.conf" -reconfigure 

}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

