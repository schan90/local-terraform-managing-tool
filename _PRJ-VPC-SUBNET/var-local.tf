# --- root : 1_VPC/var-local.tf

locals {
  region   = var.aws_region
  vpc_name = "${var.env}-${var.vpc_prefix}"

  owners      = var.vpc_prefix
  environment = var.env

  common_tags = {
    owners      = local.owners
    environment = local.environment
  }

}

###################
data "terraform_remote_state" "s3" {

  backend = "s3"
  config = {
    bucket = var.bucket
    key    = "env://${var.env}/${var.key}"
    region = var.aws_region
  }
}

#######################
variable "env" { type = string }
variable "aws_profile" { type = string }
variable "aws_region" { type = string }
variable "vpc_prefix" { type = string }

variable "bucket" { type = string }
variable "key" { type = string }

###################

# VPC Name
# variable "vpc_name" { type = string }

# variable "vpc_id" { type        = string }

# VPC CIDR Block
variable "vpc_cidr_block" { type = string }

# VPC Availability Zones
variable "vpc_availability_zones" { type = list(string) }

# VPC Public Subnets
variable "vpc_public_subnets" { type = list(string) }

# VPC Private Subnets
variable "vpc_private_subnets" { type = list(string) }

# VPC Enable NAT Gateway (True or False) 
variable "vpc_enable_nat_gateway" { type = bool }

# VPC Single NAT Gateway (True or False)
variable "vpc_single_nat_gateway" { type = bool }

####################################
# VPC Database Subnets
variable "vpc_database_subnets" { type = list(string) }

# VPC Create Database Subnet Group (True / False)
variable "vpc_create_database_subnet_group" { type = bool }

# VPC Create Database Subnet Route Table (True or False)
variable "vpc_create_database_subnet_route_table" { type = bool }

###################


