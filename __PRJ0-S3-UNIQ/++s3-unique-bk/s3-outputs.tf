output "s3-name-out" {
  value = aws_s3_bucket.uniq_bk.id
}

output "dy-name-out" {
  
  value = aws_dynamodb_table.terraform_locks.id
}