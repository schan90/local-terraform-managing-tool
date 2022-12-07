locals {
  region      = var.aws_region
  bucket_name = "${var.env}-${var.s3_bucketprefix}-"

  table_name = join("-", [var.env, var.dy_tablename, random_string.suffix_num.result])
}

#######################

variable "env" { type = string }
variable "aws_profile" { type = string }
variable "aws_region" { type = string }

variable "suffixnum" { type = number }

############

variable "dy_tablename" { type = string }

variable "s3_bucketprefix" { type = string }

################################