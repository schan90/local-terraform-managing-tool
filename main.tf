
###############################
module "s3_bucket-uniq" {
  source = "./++s3-unique-bk"

  s3_bucketprefix_in = local.bucket_name
  dy_table_name_in   = local.table_name
}

resource "random_string" "suffix_num" {
  length  = var.suffixnum
  special = false
  upper   = false
}

#############
