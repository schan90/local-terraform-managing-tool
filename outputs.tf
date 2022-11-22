output "s3-name" {
  # value = "${data.local_file.s3name.content}"
  value = module.s3_bucket-uniq.s3-name-out
}

output "dy-name" {
  value = module.s3_bucket-uniq.dy-name-out
}

output "workspace" {
  value = terraform.workspace
}

